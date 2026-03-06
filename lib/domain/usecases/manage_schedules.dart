import '../entities/schedule.dart';
import '../entities/schedule_history.dart';
import '../repositories/schedule_repository.dart';

/// Use cases for managing existing schedules (get, delete, toggle).
class ManageSchedules {
  final ScheduleRepository _repository;

  ManageSchedules(this._repository);

  /// Get all active schedules sorted by scheduled time.
  Future<List<Schedule>> getAllSchedules() async {
    final schedules = await _repository.getAllSchedules();
    // Sort by next execution time (soonest first)
    schedules.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
    return schedules;
  }

  /// Get a schedule by ID.
  Future<Schedule?> getById(int id) async {
    return _repository.getScheduleById(id);
  }

  /// Delete a schedule.
  Future<void> delete(int id) async {
    await _repository.deleteSchedule(id);
  }

  /// Toggle a schedule's active state.
  Future<void> toggleActive(Schedule schedule) async {
    final updated = schedule.copyWith(isActive: !schedule.isActive);
    await _repository.updateSchedule(updated);
  }

  /// Get execution history.
  Future<List<ScheduleHistory>> getHistory() async {
    return _repository.getHistory();
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
  }
}
