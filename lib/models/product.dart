import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int supplierId;

  Product({
    required this.name,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.supplierId,
  });
}