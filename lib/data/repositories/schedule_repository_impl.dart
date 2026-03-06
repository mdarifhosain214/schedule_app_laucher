import '../../core/constants/app_constants.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_history.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/local_database.dart';
import '../models/schedule_model.dart';
import '../models/schedule_history_model.dart';

/// Concrete implementation of [ScheduleRepository] using SQLite.
class ScheduleRepositoryImpl implements ScheduleRepository {
  final LocalDatabase _localDatabase;

  ScheduleRepositoryImpl(this._localDatabase);

  @override
  Future<List<Schedule>> getAllSchedules() async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      AppConstants.schedulesTable,
      orderBy: 'scheduled_date_time ASC',
    );
    return maps.map((m) => ScheduleModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Schedule?> getScheduleById(int id) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      AppConstants.schedulesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ScheduleModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<int> insertSchedule(Schedule schedule) async {
    final db = await _localDatabase.database;
    final model = ScheduleModel.fromEntity(schedule);
    return db.insert(AppConstants.schedulesTable, model.toMap());
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    final db = await _localDatabase.database;
    final model = ScheduleModel.fromEntity(schedule);
    await db.update(
      AppConstants.schedulesTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  @override
  Future<void> deleteSchedule(int id) async {
    final db = await _localDatabase.database;
    await db.delete(
      AppConstants.schedulesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Schedule?> findConflict(DateTime dateTime, {int? excludeId}) async {
    final db = await _localDatabase.database;

    // Two schedules conflict if they share the same minute
    // We check +/- 30 seconds around the target time
    final target = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    final start = target.toIso8601String();
    final end = target.add(const Duration(minutes: 1)).toIso8601String();

    String whereClause =
        'scheduled_date_time >= ? AND scheduled_date_time < ? AND is_active = 1';
    List<dynamic> whereArgs = [start, end];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final maps = await db.query(
      AppConstants.schedulesTable,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ScheduleModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<void> insertHistory(ScheduleHistory history) async {
    final db = await _localDatabase.database;
    final model = ScheduleHistoryModel.fromEntity(history);
    await db.insert(AppConstants.historyTable, model.toMap());
  }

  @override
  Future<List<ScheduleHistory>> getHistory() async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      AppConstants.historyTable,
      orderBy: 'executed_at DESC',
    );
    return maps
        .map((m) => ScheduleHistoryModel.fromMap(m).toEntity())
        .toList();
  }

  @override
  Future<void> clearHistory() async {
    final db = await _localDatabase.database;
    await db.delete(AppConstants.historyTable);
  }
}
