import 'package:package_info_plus/package_info_plus.dart';

import '../domain/app_info.dart';
import '../domain/app_info_service.dart';

class PackageInfoAppInfoService implements AppInfoService {
  AppInfo? _cached;

  @override
  Future<AppInfo> load() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final appInfo = AppInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );

    _cached = appInfo;
    return appInfo;
  }
}
