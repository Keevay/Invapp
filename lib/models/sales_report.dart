import 'package:hive/hive.dart';

part 'sales_report.g.dart';

@HiveType(typeId: 7)
class SalesReport extends HiveObject {
  @HiveField(0)
  final String reportId;

  @HiveField(1)
  final String cashierName;

  @HiveField(2)
  final DateTime generatedDate;

  @HiveField(3)
  final int totalSalesCount;

  @HiveField(4)
  final double totalAmount;

  SalesReport({
    required this.reportId,
    required this.cashierName,
    required this.generatedDate,
    required this.totalSalesCount,
    required this.totalAmount,
  });
}
