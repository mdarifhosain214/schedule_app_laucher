import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  static Future<void> requestPermissions() async {
    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request exact alarm permission (Android 14+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Request draw over other apps permission (Android 10+ for background launch)
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }
}
