import 'package:hive/hive.dart';

part 'activity_log.g.dart';

@HiveType(typeId: 4)
class ActivityLog extends HiveObject {
  @HiveField(0)
  final String action;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? reportId;

  ActivityLog({
    required this.action,
    required this.description,
    required this.timestamp,
    this.reportId,
  });
}
