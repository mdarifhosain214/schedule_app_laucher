import '../entities/schedule.dart';
import '../entities/schedule_history.dart';

/// Abstract repository interface for schedule CRUD operations.
abstract class ScheduleRepository {
  /// Get all active schedules sorted by scheduled time.
  Future<List<Schedule>> getAllSchedules();

  /// Get a single schedule by ID.
  Future<Schedule?> getScheduleById(int id);

  /// Insert a new schedule and return its ID.
  Future<int> insertSchedule(Schedule schedule);

  /// Update an existing schedule.
  Future<void> updateSchedule(Schedule schedule);

  /// Delete a schedule by ID.
  Future<void> deleteSchedule(int id);

  /// Check if there's a conflicting schedule at the given time.
  /// Returns the conflicting schedule if found, null otherwise.
  /// If [excludeId] is provided, that schedule is ignored (for editing).
  Future<Schedule?> findConflict(DateTime dateTime, {int? excludeId});

  /// Insert a history record.
  Future<void> insertHistory(ScheduleHistory history);

  /// Get all history records, most recent first.
  Future<List<ScheduleHistory>> getHistory();

  /// Clear all history records.
  Future<void> clearHistory();
}
