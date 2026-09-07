import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wifi_connect_to_platform_interface.dart';

/// An implementation of [WifiConnectToPlatform] that uses method channels.
class MethodChannelWifiConnectTo extends WifiConnectToPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wifi_connect_to');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
