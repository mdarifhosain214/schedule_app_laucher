import 'dart:typed_data';

/// Domain entity representing a scheduled app launch.
class Schedule {
  final int? id;
  final String appName;
  final String packageName;
  final Uint8List? appIcon;
  final String? label;
  final DateTime scheduledDateTime;
  final bool isActive;
  final DateTime createdAt;

  const Schedule({
    this.id,
    required this.appName,
    required this.packageName,
    this.appIcon,
    this.label,
    required this.scheduledDateTime,
    this.isActive = true,
    required this.createdAt,
  });

  Schedule copyWith({
    int? id,
    String? appName,
    String? packageName,
    Uint8List? appIcon,
    String? label,
    DateTime? scheduledDateTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      appIcon: appIcon ?? this.appIcon,
      label: label ?? this.label,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schedule &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Schedule(id: $id, app: $appName, time: $scheduledDateTime, active: $isActive)';
}
