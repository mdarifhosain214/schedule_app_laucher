import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_discovery_datasource.dart';

/// Concrete implementation of [AppRepository] using platform channels.
class AppRepositoryImpl implements AppRepository {
  final AppDiscoveryDatasource _datasource;

  AppRepositoryImpl(this._datasource);

  @override
  Future<List<AppInfo>> getInstalledApps() {
    return _datasource.getInstalledApps();
  }

  @override
  Future<bool> launchApp(String packageName) {
    return _datasource.launchApp(packageName);
  }
}
