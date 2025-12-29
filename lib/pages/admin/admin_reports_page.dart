import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invapp/models/product.dart';
import 'package:invapp/models/user.dart';
import 'package:invapp/models/supplier.dart';
import 'package:invapp/models/sales_report.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productBox = Hive.box<Product>('products');
    final userBox = Hive.box<User>('users');
    final supplierBox = Hive.box<Supplier>('suppliers');
    // Check for recent reports (e.g., today)
    // Note: This requires 'sales_reports' box to be open. It is opened in main.dart.
    final reportBox = Hive.box<SalesReport>('sales_reports');
    final today = DateTime.now();
    final latestReport = reportBox.values.toList()
        .where((r) => 
            r.generatedDate.year == today.year && 
            r.generatedDate.month == today.month && 
            r.generatedDate.day == today.day)
        .toList();
    // Sort by date desc
    latestReport.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
    
    final SalesReport? recentReport = latestReport.isNotEmpty ? latestReport.first : null;

    final totalProducts = productBox.length;
    final totalUsers = userBox.length;
    final totalSuppliers = supplierBox.length;

    final lowStockProducts = productBox.values.where((p) => p.quantity < 5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert for New Report
          if (recentReport != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.indigo),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("New Sales Report Received", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        Text("Submitted by ${recentReport.cashierName} at ${recentReport.generatedDate.hour}:${recentReport.generatedDate.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Text(
            "Dashboard Overview", 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Welcome back, Admin. Here is what is happening today.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final cardList = [
                _StatCard(
                  title: 'Total Products',
                  value: totalProducts.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Total Suppliers', 
                  value: totalSuppliers.toString(),
                  icon: Icons.local_shipping_outlined,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Total Users', 
                  value: totalUsers.toString(),
                  icon: Icons.people_outline,
                  color: Colors.purple,
                ),
                if (constraints.maxWidth > 900 || lowStockProducts.isNotEmpty)
                  _StatCard(
                    title: 'Low Stock',
                    value: lowStockProducts.length.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
              ];

              if (isDesktop) {
                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cardList,
                );
              } else {
                return SizedBox(
                  height: 150, // Fixed height for horizontal list
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cardList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 240, // Fixed width for comfortable horizontal scrolling
                        child: cardList[index],
                      );
                    },
                  ),
                );
              }
            }
          ),

          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                "Low Stock Alerts", 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
               ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (lowStockProducts.isEmpty)
             Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
               child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Text("All products are well stocked!", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500)),
                ],
               ),
             )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: lowStockProducts.length,
                separatorBuilder: (ctx, i) => Divider(height: 1),
                itemBuilder: (context, index) {
                   final p = lowStockProducts[index];
                   return ListTile(
                     leading: Container(
                       padding: EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Colors.red.withOpacity(0.1),
                         shape: BoxShape.circle,
                       ),
                       child: Icon(Icons.priority_high, color: Colors.red, size: 20),
                     ),
                     title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w600)),
                     subtitle: Text('Current Quantity: ${p.quantity}'),
                     trailing: Chip(
                       label: Text('Restock Needed'),
                       backgroundColor: Colors.red.withOpacity(0.1),
                       labelStyle: TextStyle(color: Colors.red, fontSize: 12),
                       padding: EdgeInsets.zero,
                       visualDensity: VisualDensity.compact,
                     ),
                   );
                },
              ),
            ),

          const SizedBox(height: 48),
          Text(
            "Product Stock Analytics", 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.7,
            child: Card(
              elevation: 0,
              color: Colors.transparent, // Let grid show through or cleaner look
              child: ProductBarChart(),
            ),
          ),

          const SizedBox(height: 48),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Export Annual Report'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
              onPressed: () => _exportReportAsPdf(context),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

void _exportReportAsPdf(BuildContext context) async {
  final productBox = Hive.box<Product>('products');
  final userBox = Hive.box<User>('users');
  final supplierBox = Hive.box<Supplier>('suppliers');

  final totalProducts = productBox.length;
  final totalUsers = userBox.length;
  final totalSuppliers = supplierBox.length;
  final lowStockProducts = productBox.values.where((p) => p.quantity < 5).toList();

  final now = DateTime.now();
  final formattedDate =
      "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text("Inventory Performance Report", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text("Generated on $formattedDate", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
        pw.Divider(),

        pw.SizedBox(height: 16),
        pw.Text("Executive Summary", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          "This report provides an overview of the current inventory, user activity, and supplier distribution in the system. "
          "It highlights low stock alerts that may require immediate restocking actions.",
        ),

        pw.SizedBox(height: 20),
        pw.Text("Summary Statistics", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: "Total Products in Inventory: $totalProducts"),
        pw.Bullet(text: "Total Suppliers Registered: $totalSuppliers"),
        pw.Bullet(text: "Total Users Registered: $totalUsers"),

        pw.SizedBox(height: 20),
        pw.Text("Low Stock Alerts", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        lowStockProducts.isEmpty
            ? pw.Text("No low-stock products at this time.")
            : pw.Table.fromTextArray(
                headers: ["Product Name", "Quantity"],
                data: lowStockProducts.map((p) => [p.name, p.quantity.toString()]).toList(),
              ),

        pw.SizedBox(height: 30),
        pw.Text("Notes", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(
          "This report is system-generated and reflects data available at the time of export. "
          "For real-time updates, please refer to the live dashboard.",
        ),

        pw.SizedBox(height: 40),
        pw.Text("Authorized by: _________________________", style: pw.TextStyle(fontSize: 12)),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}



class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title, 
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
           BoxShadow(
            color: color.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              // Optional: Add trend indicator?
             ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value, 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                )
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ProductBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productBox = Hive.box<Product>('products');
    final products = productBox.values.toList();

    if (products.isEmpty) {
      return const Center(child: Text("No data to display"));
    }

    // Get today and past 6 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day); // Strip time
    });

    // Group by day and sum quantities
    final Map<DateTime, int> dailyTotals = {
      for (var day in last7Days) day: 0
    };

    for (var product in products) {
      final createdAt = DateTime(
        product.createdAt.year,
        product.createdAt.month,
        product.createdAt.day,
      );
      if (dailyTotals.containsKey(createdAt)) {
        dailyTotals[createdAt] = dailyTotals[createdAt]! + product.quantity;
      }
    }

    final values = dailyTotals.values.toList();
    final highestQuantity = values.reduce((a, b) => a > b ? a : b);
    final maxY = highestQuantity + 5;

    // Dynamic step size for Y-axis
    double step = 1;
    if (maxY > 50) {
      step = 10;
    } else if (maxY > 20) {
      step = 5;
    } else if (maxY > 10) {
      step = 2;
    }

    final barGroups = List.generate(7, (i) {
      final day = last7Days[i];
      final quantity = dailyTotals[day] ?? 0;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: quantity.toDouble(),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 32,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY.toDouble(),
              color: Colors.grey.withOpacity(0.05),
            )
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        maxY: maxY.toDouble(),
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
             tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: step,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}', 
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index < 0 || index >= 7) return const SizedBox.shrink();
                final day = last7Days[index];
                final label = "${day.month}/${day.day}";
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    label, 
                    style: TextStyle(
                      color: Colors.grey[600], 
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    )
                  ),
                );
              },
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: barGroups,
      ),
    );
  }
}


