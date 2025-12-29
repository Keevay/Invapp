import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password; // store hashed password in production!

  @HiveField(2)
  String role; // "admin" or "user"

  User({
    required this.username,
    required this.password,
    required this.role,
  });
}