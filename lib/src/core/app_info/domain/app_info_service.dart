import 'app_info.dart';

abstract class AppInfoService {
  Future<AppInfo> load();
}
