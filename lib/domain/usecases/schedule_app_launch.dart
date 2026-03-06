import '../../core/utils/date_time_utils.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

/// Result of a schedule creation/update attempt.
class ScheduleResult {
  final bool success;
  final String? errorMessage;
  final Schedule? conflictingSchedule;
  final int? scheduleId;

  const ScheduleResult._({
    required this.success,
    this.errorMessage,
    this.conflictingSchedule,
    this.scheduleId,
  });

  factory ScheduleResult.success(int id) =>
      ScheduleResult._(success: true, scheduleId: id);

  factory ScheduleResult.conflict(Schedule conflicting) => ScheduleResult._(
        success: false,
        errorMessage:
            'Conflict: "${conflicting.appName}" is already scheduled at this time.',
        conflictingSchedule: conflicting,
      );

  factory ScheduleResult.error(String message) =>
      ScheduleResult._(success: false, errorMessage: message);
}

/// Use case for creating and updating schedules with conflict detection.
class ScheduleAppLaunch {
  final ScheduleRepository _repository;

  ScheduleAppLaunch(this._repository);

  /// Create a new schedule. Returns [ScheduleResult] indicating success or conflict.
  Future<ScheduleResult> call(Schedule schedule) async {
    // Validate that the time is in the future
    if (!DateTimeUtils.isFuture(schedule.scheduledDateTime)) {
      return ScheduleResult.error('Scheduled time must be in the future.');
    }

    // Check for conflicts
    final conflict = await _repository.findConflict(schedule.scheduledDateTime);
    if (conflict != null) {
      return ScheduleResult.conflict(conflict);
    }

    final id = await _repository.insertSchedule(schedule);
    return ScheduleResult.success(id);
  }

  /// Update an existing schedule with conflict detection.
  Future<ScheduleResult> update(Schedule schedule) async {
    if (schedule.id == null) {
      return ScheduleResult.error('Cannot update a schedule without an ID.');
    }

    if (!DateTimeUtils.isFuture(schedule.scheduledDateTime)) {
      return ScheduleResult.error('Scheduled time must be in the future.');
    }

    // Check for conflicts excluding this schedule's ID
    final conflict = await _repository.findConflict(
      schedule.scheduledDateTime,
      excludeId: schedule.id,
    );
    if (conflict != null) {
      return ScheduleResult.conflict(conflict);
    }

    await _repository.updateSchedule(schedule);
    return ScheduleResult.success(schedule.id!);
  }
}
