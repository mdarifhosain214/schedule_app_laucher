import '../../domain/entities/schedule_history.dart';

/// Data model for serializing/deserializing ScheduleHistory to/from SQLite.
class ScheduleHistoryModel {
  final int? id;
  final int scheduleId;
  final String appName;
  final String packageName;
  final DateTime executedAt;
  final bool wasSuccessful;

  const ScheduleHistoryModel({
    this.id,
    required this.scheduleId,
    required this.appName,
    required this.packageName,
    required this.executedAt,
    this.wasSuccessful = true,
  });

  factory ScheduleHistoryModel.fromEntity(ScheduleHistory entity) {
    return ScheduleHistoryModel(
      id: entity.id,
      scheduleId: entity.scheduleId,
      appName: entity.appName,
      packageName: entity.packageName,
      executedAt: entity.executedAt,
      wasSuccessful: entity.wasSuccessful,
    );
  }

  factory ScheduleHistoryModel.fromMap(Map<String, dynamic> map) {
    return ScheduleHistoryModel(
      id: map['id'] as int?,
      scheduleId: map['schedule_id'] as int,
      appName: map['app_name'] as String,
      packageName: map['package_name'] as String,
      executedAt: DateTime.parse(map['executed_at'] as String),
      wasSuccessful: (map['was_successful'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'schedule_id': scheduleId,
      'app_name': appName,
      'package_name': packageName,
      'executed_at': executedAt.toIso8601String(),
      'was_successful': wasSuccessful ? 1 : 0,
    };
  }

  ScheduleHistory toEntity() {
    return ScheduleHistory(
      id: id,
      scheduleId: scheduleId,
      appName: appName,
      packageName: packageName,
      executedAt: executedAt,
      wasSuccessful: wasSuccessful,
    );
  }
}
