import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/activity_log.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late Box<Product> _productBox;
  late Box<Supplier> _supplierBox;
  
  String _searchQuery = '';
  String _sortBy = 'name'; // name, price, quantity

  @override
  void initState() {
    super.initState();
    _productBox = Hive.box<Product>('products');
    _supplierBox = Hive.box<Supplier>('suppliers');
  }

  List<Product> _getFilteredProducts() {
    final products = _productBox.values.toList();
    
    // Filter
    var filtered = products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'price':
          return a.price.compareTo(b.price);
        case 'quantity':
          return a.quantity.compareTo(b.quantity);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }



  void _logActivity(String action, String description) {
    if (Hive.isBoxOpen('activity_logs')) {
      final box = Hive.box<ActivityLog>('activity_logs');
      box.add(ActivityLog(
        action: action,
        description: description,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _addOrEditProduct({Product? existingProduct, int? index}) {
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final quantityController = TextEditingController(text: existingProduct?.quantity.toString() ?? '');
    final priceController = TextEditingController(text: existingProduct?.price.toString() ?? '');

    Supplier? selectedSupplier = existingProduct != null
        ? _supplierBox.get(existingProduct.supplierId)
        : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingProduct == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Supplier>(
                  value: selectedSupplier,
                  hint: const Text('Select Supplier'),
                  items: _supplierBox.values.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSupplier = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;

                if (name.isNotEmpty && selectedSupplier != null) {
                  final newProduct = Product(
                    name: name,
                    quantity: quantity,
                    price: price,
                    createdAt: DateTime.now(),
                    supplierId: selectedSupplier!.key as int,
                  );

                  if (existingProduct == null) {
                    _productBox.add(newProduct);
                    _logActivity('Add Product', 'Added product: $name');
                  } else if (index != null) {
                    _productBox.putAt(index, newProduct);
                     _logActivity('Update Product', 'Updated product: $name');
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(existingProduct == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(int index) {
    final product = _productBox.getAt(index);
    if (product != null) {
       _logActivity('Delete Product', 'Deleted product: ${product.name}');
    }
    _productBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              SizedBox(width: 16),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: Icon(Icons.sort),
                    onChanged: (val) => setState(() => _sortBy = val!),
                    items: [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _addOrEditProduct(),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
        ),
        
        // List Section (Responsive)
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _productBox.listenable(),
            builder: (context, Box<Product> box, _) {
              final products = _getFilteredProducts();
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text('No products found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Desktop View (Table)
                  if (constraints.maxWidth > 700) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.05)),
                            columns: [
                              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: products.map((product) {
                              // We need the original index for Hive operations
                              // This is a bit tricky with filtered list, better to store key or re-find
                              // For simplicity in this Hive setup, we'll find index in values
                              // A robust app would use keys.
                              final index = _productBox.values.toList().indexOf(product);
                              final supplierName = _supplierBox.get(product.supplierId)?.name ?? 'Unknown';

                              return DataRow(cells: [
                                DataCell(Text(product.name, style: TextStyle(fontWeight: FontWeight.w500))),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: product.quantity < 5 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product.quantity.toString(),
                                      style: TextStyle(
                                        color: product.quantity < 5 ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                                DataCell(Text(supplierName)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () => _addOrEditProduct(existingProduct: product, index: index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => _deleteProduct(index),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }

                  // Mobile View (Cards)
                  return ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (ctx, i) => SizedBox(height: 12),
                    itemBuilder: (_, listIndex) {
                      final product = products[listIndex];
                      final index = _productBox.values.toList().indexOf(product);
                      final supplierName = _supplierBox.get(product.supplierId)?.name ?? 'Unknown';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text('Qty: ${product.quantity}', style: TextStyle(color: product.quantity < 5 ? Colors.red : Colors.black87)),
                                  Spacer(),
                                  Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(supplierName, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: Icon(Icons.edit, size: 18),
                                    label: Text("Edit"),
                                    onPressed: () => _addOrEditProduct(existingProduct: product, index: index),
                                  ),
                                  TextButton.icon(
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                                    label: Text("Delete", style: TextStyle(color: Colors.red)),
                                    onPressed: () => _deleteProduct(index),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
