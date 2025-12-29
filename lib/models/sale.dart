import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 5)
class SaleItem extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double unitPrice;

  SaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

@HiveType(typeId: 6)
class Sale extends HiveObject {
  @HiveField(0)
  final String saleId;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final List<SaleItem> items;

  @HiveField(4)
  final String cashierName;

  Sale({
    required this.saleId,
    required this.date,
    required this.totalAmount,
    required this.items,
    required this.cashierName,
  });
}
