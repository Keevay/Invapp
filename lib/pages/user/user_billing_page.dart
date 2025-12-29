import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../models/sale.dart';
import '../../models/sales_report.dart';
import '../../models/activity_log.dart';
import '../../models/user.dart';

class UserBillingPage extends StatefulWidget {
  const UserBillingPage({super.key});

  @override
  State<UserBillingPage> createState() => _UserBillingPageState();
}

class _UserBillingPageState extends State<UserBillingPage> {
  late Box<Product> _productBox;
  late Box<Sale> _saleBox;
  late Box<SalesReport> _reportBox;
  late Box<ActivityLog> _logBox;
  
  // Cart State
  final List<SaleItem> _cart = [];
  String _searchQuery = '';
  
  // Report State
  late Box<User> _userBox; // To get current user info if stored, or we pass it. 
  // For simplicity, we assume 'user1' or retrieve from session. 
  // Ideally, we should have a SessionManager. We'll use a placeholder or the global user box if we knew who logged in.
  // We'll trust the Login page stored the current user's role/name? 
  // Actually, the app doesn't seem to track "Current User" globally yet.
  // I'll assume 'Cashier' for now or get it from Hive if possible.
  // Let's assume the username is 'Employee' or fetched.
  String _currentCashierName = 'Employee';

  @override
  void initState() {
    super.initState();
    _productBox = Hive.box<Product>('products');
    _saleBox = Hive.box<Sale>('sales');
    _reportBox = Hive.box<SalesReport>('sales_reports');
    _logBox = Hive.box<ActivityLog>('activity_logs');
    _userBox = Hive.box<User>('users');
    
    // Attempt to match a user if possible, or just default.
    // In a real app we'd pass the user via constructor.
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.total);

  void _addToCart(Product product) {
    if (product.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product is out of stock!")));
      return;
    }

    // Check if already in cart
    final existingIndex = _cart.indexWhere((item) => item.productName == product.name);
    
    // Check if adding exceeds stock
    int currentInCart = existingIndex != -1 ? _cart[existingIndex].quantity : 0;
    if (currentInCart + 1 > product.quantity) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Available stock limit reached!")));
       return;
    }

    setState(() {
      if (existingIndex != -1) {
        // Replace with updated quantity. SaleItem is immutable so we create new.
        final oldItem = _cart[existingIndex];
        _cart[existingIndex] = SaleItem(
          productName: oldItem.productName,
          quantity: oldItem.quantity + 1,
          unitPrice: oldItem.unitPrice,
        );
      } else {
        _cart.add(SaleItem(
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }
  
  void _updateCartQuantity(int index, int delta) {
    setState(() {
      final item = _cart[index];
      final newQuantity = item.quantity + delta;
      
      // Get product to check stock limit
      final product = _productBox.values.firstWhere((p) => p.name == item.productName);
      
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else if (newQuantity <= product.quantity) {
         _cart[index] = SaleItem(
            productName: item.productName,
            quantity: newQuantity,
            unitPrice: item.unitPrice,
         );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot exceed available stock!")));
      }
    });
  }

  void _processCheckout() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Sale"),
        content: Text("Total Amount: \$${_cartTotal.toStringAsFixed(2)}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(ctx);
               _finalizeSale();
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  void _finalizeSale() {
    // 1. Update Inventory
    for (var item in _cart) {
      final productKey = _productBox.values.toList().indexWhere((p) => p.name == item.productName);
      if (productKey != -1) {
        final product = _productBox.getAt(productKey)!;
        product.quantity -= item.quantity;
        product.save();
      }
    }

    // 2. Create Sale Record
    final sale = Sale(
      saleId: const Uuid().v4(),
      date: DateTime.now(),
      totalAmount: _cartTotal,
      items: List.from(_cart),
      cashierName: _currentCashierName,
    );
    _saleBox.add(sale);

    // 3. Log Activity
    _logBox.add(ActivityLog(
      action: 'Sale', 
      description: 'Processed sale of \$${_cartTotal.toStringAsFixed(2)}', 
      timestamp: DateTime.now()
    ));

    // 4. Clear Cart & Notify
    setState(() {
      _cart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sale successful!")));
  }

  // --- Reporting Logic ---

  void _submitShiftReport() async {
    // Logic: Find all sales by this user TODAY (or since last report? sticking to 'Today' for simplicity per plan update)
    // Actually, "Submit Report" implies checking sales that match a criteria. 
    // Let's assume we report ALL sales today made by this user.
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final todaysSales = _saleBox.values.where((s) => 
      s.cashierName == _currentCashierName && 
      s.date.isAfter(startOfDay)
    ).toList();

    if (todaysSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No sales found for today to report.")));
      return;
    }

    // Calculate totals
    final totalAmount = todaysSales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final reportId = const Uuid().v4();

    // Create Report
    final report = SalesReport(
      reportId: reportId,
      cashierName: _currentCashierName,
      generatedDate: now,
      totalSalesCount: todaysSales.length,
      totalAmount: totalAmount,
    );
    _reportBox.add(report);

    // Generate PDF
    await _generateAndShowPdf(report, todaysSales);

    // Log with Report ID
    _logBox.add(ActivityLog(
      action: 'Report Submitted',
      description: 'Sales report submitted by $_currentCashierName',
      timestamp: now,
      reportId: reportId,
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted successfully!")));
  }

  Future<void> _generateAndShowPdf(SalesReport report, List<Sale> sales) async {
     final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Sales Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Cashier: ${report.cashierName}"),
            pw.Text("Date: ${DateFormat('yyyy-MM-dd HH:mm').format(report.generatedDate)}"),
            pw.Text("Total Sales: ${report.totalSalesCount}"),
            pw.Text("Total Revenue: \$${report.totalAmount.toStringAsFixed(2)}"),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Sale ID', 'Time', 'Items', 'Amount'],
              data: sales.map((s) => [
                s.saleId.substring(0, 8),
                DateFormat('HH:mm').format(s.date),
                s.items.length.toString(),
                '\$${s.totalAmount.toStringAsFixed(2)}'
              ]).toList(),
            ),
          ]
        );
      }
    ));

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    // Filter Products
    final products = _productBox.values.where((p) => 
      _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
    
    // Layout:
    // Mobile: Two tabs? Or just Search list + Floating Cart button?
    // Let's use a Column with Expanded List and a Bottom Sheet like container for Cart.
    // Or simpler: Split view if wide, Stack if narrow.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: "Submit Daily Report",
            onPressed: _submitShiftReport,
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          Expanded(
            child: Row(
              children: [
                // Product List
                Expanded(
                  flex: 2,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final p = products[i];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Price: \$${p.price} | Stock: ${p.quantity}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                            onPressed: () => _addToCart(p),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Cart Section (Visible on side for Desktop/Tablet, or should check constraints?)
                // For simplicity, let's keep it robust. If mobile, maybe checkout is a bottom sheet?
                // Let's stick to a robust side-by-side for now, it works for 'Horizontal layout' logic too if we consider the screen big enough,
                // but for mobile phone... user asked for mobile friendly.
                // On mobile, the cart should probably be a separate view or a bottom sheet.
                // Let's verify width.
              ],
            ),
          ),
        ],
      ),
      // Cart Summary / Checkout Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart Preview (Small list)
            if (_cart.isNotEmpty)
              Container(
                 constraints: const BoxConstraints(maxHeight: 150),
                 child: ListView.builder(
                   shrinkWrap: true,
                   itemCount: _cart.length,
                   itemBuilder: (ctx, i) {
                     final item = _cart[i];
                     return Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(child: Text("${item.productName} x${item.quantity}")),
                         Row(
                           children: [
                             IconButton(icon: Icon(Icons.remove_circle_outline, size: 20, color: Colors.red), onPressed: () => _updateCartQuantity(i, -1)),
                             IconButton(icon: Icon(Icons.add_circle_outline, size: 20, color: Colors.green), onPressed: () => _updateCartQuantity(i, 1)),
                             SizedBox(width: 8),
                             Text("\$${item.total.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                           ],
                         )
                       ],
                     );
                   },
                 ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: \$${_cartTotal.toStringAsFixed(2)}", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: _cart.isNotEmpty ? _processCheckout : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Checkout"),
                ),
              ],
            ),
            // We need a Checkout button text fix
          ],
        ),
      ),
    );
  }
}
