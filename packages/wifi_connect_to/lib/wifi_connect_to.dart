import 'wifi_connect_to_platform_interface.dart';

class WifiConnectTo {
  Future<String?> getPlatformVersion() {
    return WifiConnectToPlatform.instance.getPlatformVersion();
  }
}
