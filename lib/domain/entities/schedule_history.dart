/// Domain entity representing a record of a schedule execution.
class ScheduleHistory {
  final int? id;
  final int scheduleId;
  final String appName;
  final String packageName;
  final DateTime executedAt;
  final bool wasSuccessful;

  const ScheduleHistory({
    this.id,
    required this.scheduleId,
    required this.appName,
    required this.packageName,
    required this.executedAt,
    this.wasSuccessful = true,
  });

  @override
  String toString() =>
      'ScheduleHistory(id: $id, app: $appName, executed: $executedAt, success: $wasSuccessful)';
}
