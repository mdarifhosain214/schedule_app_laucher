import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Service for scheduling and cancelling native Android alarms
/// via platform channel. The native side handles app launching,
/// database updates, and notifications — no background Dart isolate needed.
class AlarmService {
  AlarmService._();

  static const _channel = MethodChannel(AppConstants.platformChannel);

  /// Initialize — no-op for native alarms, kept for API compatibility.
  static Future<void> initialize() async {
    // Native AlarmManager doesn't need Dart-side initialization.
  }

  /// Schedule a native exact alarm for a given schedule.
  static Future<bool> scheduleAlarm({
    required int scheduleId,
    required DateTime dateTime,
    required String packageName,
    required String appName,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'scheduleId': scheduleId,
        'dateTimeMillis': dateTime.millisecondsSinceEpoch,
        'packageName': packageName,
        'appName': appName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to schedule alarm: ${e.message}');
    }
  }

  /// Cancel a native alarm for a given schedule ID.
  static Future<bool> cancelAlarm(int scheduleId) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAlarm', {
        'scheduleId': scheduleId,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to cancel alarm: ${e.message}');
    }
  }
}
