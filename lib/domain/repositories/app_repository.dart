import '../entities/app_info.dart';

/// Abstract repository interface for app discovery.
abstract class AppRepository {
  /// Retrieve list of all installed apps on the device.
  Future<List<AppInfo>> getInstalledApps();

  /// Launch an app by its package name.
  Future<bool> launchApp(String packageName);
}
