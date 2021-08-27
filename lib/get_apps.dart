import 'package:device_apps/device_apps.dart';

class get_apps{
  static Future<List<Application>> getApps(bool systemApp) async{
    List<Application> apps = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: systemApp);
    apps.sort((a,b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    return apps;
  }

}