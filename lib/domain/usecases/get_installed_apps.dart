import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

/// Use case that retrieves all installed apps from the device.
class GetInstalledApps {
  final AppRepository _repository;

  GetInstalledApps(this._repository);

  Future<List<AppInfo>> call() async {
    return _repository.getInstalledApps();
  }

  /// Filter installed apps by a search query (matches app name or package name).
  Future<List<AppInfo>> search(String query) async {
    final apps = await _repository.getInstalledApps();
    if (query.isEmpty) return apps;

    final lowerQuery = query.toLowerCase();
    return apps.where((app) {
      return app.appName.toLowerCase().contains(lowerQuery) ||
          app.packageName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
