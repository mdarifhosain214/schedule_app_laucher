import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_discovery_datasource.dart';
import '../../data/datasources/local_database.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_history.dart';
import '../../domain/usecases/get_installed_apps.dart';
import '../../domain/usecases/manage_schedules.dart';
import '../../domain/usecases/schedule_app_launch.dart';
import '../../core/services/alarm_service.dart';

// ─── Dependencies ───

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

final appDiscoveryDatasourceProvider = Provider<AppDiscoveryDatasource>((ref) {
  return AppDiscoveryDatasource();
});

final appRepositoryProvider = Provider<AppRepositoryImpl>((ref) {
  return AppRepositoryImpl(ref.read(appDiscoveryDatasourceProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepositoryImpl>((ref) {
  return ScheduleRepositoryImpl(ref.read(localDatabaseProvider));
});

// ─── Use Cases ───

final getInstalledAppsUseCaseProvider = Provider<GetInstalledApps>((ref) {
  return GetInstalledApps(ref.read(appRepositoryProvider));
});

final scheduleAppLaunchUseCaseProvider = Provider<ScheduleAppLaunch>((ref) {
  return ScheduleAppLaunch(ref.read(scheduleRepositoryProvider));
});

final manageSchedulesUseCaseProvider = Provider<ManageSchedules>((ref) {
  return ManageSchedules(ref.read(scheduleRepositoryProvider));
});

// ─── App Discovery Providers ───

final searchQueryProvider = StateProvider<String>((ref) => '');

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final useCase = ref.read(getInstalledAppsUseCaseProvider);
  return useCase();
});

final filteredAppsProvider = Provider<AsyncValue<List<AppInfo>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final appsAsync = ref.watch(installedAppsProvider);

  return appsAsync.whenData((apps) {
    if (query.isEmpty) return apps;
    final lower = query.toLowerCase();
    return apps.where((app) {
      return app.appName.toLowerCase().contains(lower) ||
          app.packageName.toLowerCase().contains(lower);
    }).toList();
  });
});

// ─── Schedule Providers ───

final schedulesProvider =
    StateNotifierProvider<ScheduleNotifier, AsyncValue<List<Schedule>>>((ref) {
      return ScheduleNotifier(ref);
    });

class ScheduleNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final Ref _ref;
  Timer? _refreshTimer;

  ScheduleNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSchedules();
    // Periodically refresh to pick up native-side schedule deactivations
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  Future<void> _loadSchedules() async {
    try {
      state = const AsyncValue.loading();
      final useCase = _ref.read(manageSchedulesUseCaseProvider);
      final schedules = await useCase.getAllSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadSchedules();
    // Also refresh history
    _ref.invalidate(scheduleHistoryProvider);
  }

  Future<ScheduleResult> createSchedule(Schedule schedule) async {
    final useCase = _ref.read(scheduleAppLaunchUseCaseProvider);
    final result = await useCase(schedule);
    if (result.success && result.scheduleId != null) {
      // Register the native alarm
      await AlarmService.scheduleAlarm(
        scheduleId: result.scheduleId!,
        dateTime: schedule.scheduledDateTime,
        packageName: schedule.packageName,
        appName: schedule.appName,
      );
      await refresh();
    }
    return result;
  }

  Future<ScheduleResult> updateSchedule(Schedule schedule) async {
    final useCase = _ref.read(scheduleAppLaunchUseCaseProvider);
    final result = await useCase.update(schedule);
    if (result.success && schedule.id != null) {
      // Cancel old alarm and register new one
      await AlarmService.cancelAlarm(schedule.id!);
      await AlarmService.scheduleAlarm(
        scheduleId: schedule.id!,
        dateTime: schedule.scheduledDateTime,
        packageName: schedule.packageName,
        appName: schedule.appName,
      );
      await refresh();
    }
    return result;
  }

  Future<void> deleteSchedule(int id) async {
    final useCase = _ref.read(manageSchedulesUseCaseProvider);
    await AlarmService.cancelAlarm(id);
    await useCase.delete(id);
    await refresh();
  }

  Future<void> toggleActive(Schedule schedule) async {
    final useCase = _ref.read(manageSchedulesUseCaseProvider);
    await useCase.toggleActive(schedule);
    if (schedule.isActive) {
      // Was active, now deactivating → cancel alarm
      await AlarmService.cancelAlarm(schedule.id!);
    } else {
      // Was inactive, now activating → schedule alarm
      await AlarmService.scheduleAlarm(
        scheduleId: schedule.id!,
        dateTime: schedule.scheduledDateTime,
        packageName: schedule.packageName,
        appName: schedule.appName,
      );
    }
    await refresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ─── Conflict Check Provider ───

final conflictCheckProvider =
    FutureProvider.family<Schedule?, ({DateTime dateTime, int? excludeId})>((
      ref,
      params,
    ) async {
      final repo = ref.read(scheduleRepositoryProvider);
      return repo.findConflict(params.dateTime, excludeId: params.excludeId);
    });

// ─── History Provider ───

final scheduleHistoryProvider = FutureProvider<List<ScheduleHistory>>((
  ref,
) async {
  final useCase = ref.read(manageSchedulesUseCaseProvider);
  return useCase.getHistory();
});

// ─── Bottom Nav Index ───

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
