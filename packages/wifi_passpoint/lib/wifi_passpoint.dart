import 'wifi_passpoint_platform_interface.dart';

class WifiPasspoint {
  Future<String?> getPlatformVersion() {
    return WifiPasspointPlatform.instance.getPlatformVersion();
  }
}
