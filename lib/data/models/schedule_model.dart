import 'dart:typed_data';
import '../../domain/entities/schedule.dart';

/// Data model for serializing/deserializing Schedule to/from SQLite.
class ScheduleModel {
  final int? id;
  final String appName;
  final String packageName;
  final Uint8List? appIcon;
  final String? label;
  final DateTime scheduledDateTime;
  final bool isActive;
  final DateTime createdAt;

  const ScheduleModel({
    this.id,
    required this.appName,
    required this.packageName,
    this.appIcon,
    this.label,
    required this.scheduledDateTime,
    this.isActive = true,
    required this.createdAt,
  });

  /// Convert from domain entity to data model.
  factory ScheduleModel.fromEntity(Schedule entity) {
    return ScheduleModel(
      id: entity.id,
      appName: entity.appName,
      packageName: entity.packageName,
      appIcon: entity.appIcon,
      label: entity.label,
      scheduledDateTime: entity.scheduledDateTime,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from SQLite map to data model.
  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as int?,
      appName: map['app_name'] as String,
      packageName: map['package_name'] as String,
      appIcon: map['app_icon'] as Uint8List?,
      label: map['label'] as String?,
      scheduledDateTime: DateTime.parse(map['scheduled_date_time'] as String),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to SQLite-compatible map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'app_name': appName,
      'package_name': packageName,
      'app_icon': appIcon,
      'label': label,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to domain entity.
  Schedule toEntity() {
    return Schedule(
      id: id,
      appName: appName,
      packageName: packageName,
      appIcon: appIcon,
      label: label,
      scheduledDateTime: scheduledDateTime,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
