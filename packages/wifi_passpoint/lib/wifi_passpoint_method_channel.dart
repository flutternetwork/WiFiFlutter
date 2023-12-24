import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wifi_passpoint_platform_interface.dart';

/// An implementation of [WifiPasspointPlatform] that uses method channels.
class MethodChannelWifiPasspoint extends WifiPasspointPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wifi_passpoint');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
