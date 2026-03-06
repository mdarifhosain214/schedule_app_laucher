import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_info.dart';

/// Data source that communicates with Android via platform channels
/// to discover installed apps and launch them.
class AppDiscoveryDatasource {
  static const _channel = MethodChannel(AppConstants.platformChannel);

  /// Query the Android PackageManager for all installed launchable apps.
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      return result.map((app) {
        final map = Map<String, dynamic>.from(app as Map);
        Uint8List? icon;
        if (map['icon'] != null) {
          icon = Uint8List.fromList(List<int>.from(map['icon']));
        }
        return AppInfo(
          packageName: map['packageName'] as String,
          appName: map['appName'] as String,
          icon: icon,
        );
      }).toList()
        ..sort((a, b) =>
            a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } on PlatformException catch (e) {
      throw Exception('Failed to get installed apps: ${e.message}');
    }
  }

  /// Launch an app by its package name using an Android Intent.
  Future<bool> launchApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'launchApp',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to launch app: ${e.message}');
    }
  }
}
