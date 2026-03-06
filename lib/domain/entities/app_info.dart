import 'dart:typed_data';

/// Domain entity representing an installed app on the device.
class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? icon;

  const AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'AppInfo(packageName: $packageName, appName: $appName)';
}
