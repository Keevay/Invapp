import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 2)
class Supplier extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String phone;

  Supplier({
    required this.name,
    required this.email,
    required this.phone,
  });
}
