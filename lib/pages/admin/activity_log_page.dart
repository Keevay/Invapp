import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/activity_log.dart';
import '../../models/sales_report.dart';
import '../../models/sale.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure box is open (should be done in main.dart)
    // We assume it is open 'activity_logs'
    final box = Hive.box<ActivityLog>('activity_logs');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity Log',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ActivityLog> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort by date desc
          final logs = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (ctx, i) => Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              final dateStr = DateFormat('MMM dd, hh:mm a').format(log.timestamp);
              
              IconData icon;
              Color color;
              
              if (log.action.contains('Add')) {
                icon = Icons.add_circle_outline;
                color = Colors.green;
              } else if (log.action.contains('Delete')) {
                icon = Icons.delete_outline;
                color = Colors.red;
              } else if (log.action.contains('Update') || log.action.contains('Edit')) {
                icon = Icons.edit_outlined;
                color = Colors.orange;
              } else {
                icon = Icons.info_outline;
                color = Colors.blue;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(log.action, style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(log.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (log.reportId != null)
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                        tooltip: "Download Report",
                        onPressed: () {
                          _downloadReport(context, log.reportId!);
                        },
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _downloadReport(BuildContext context, String reportId) async {
     try {
       final reportBox = Hive.box<SalesReport>('sales_reports');
       final saleBox = Hive.box<Sale>('sales');
       
       // Find Report
       final report = reportBox.values.firstWhere((r) => r.reportId == reportId);
       
       // Find Sales (Same Day, Same Cashier)
       final reportDate = report.generatedDate;
       final startOfDay = DateTime(reportDate.year, reportDate.month, reportDate.day);
       final endOfDay = startOfDay.add(const Duration(days: 1));
       
       final sales = saleBox.values.where((s) => 
         s.cashierName == report.cashierName && 
         s.date.isAfter(startOfDay) && s.date.isBefore(endOfDay)
       ).toList();
       
       // Generate PDF
       final pdf = pw.Document();
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Sales Report (Copy)", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching report: $e")));
     }
  }
}
