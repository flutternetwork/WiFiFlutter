import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wifi_passpoint_method_channel.dart';

abstract class WifiPasspointPlatform extends PlatformInterface {
  /// Constructs a WifiPasspointPlatform.
  WifiPasspointPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiPasspointPlatform _instance = MethodChannelWifiPasspoint();

  /// The default instance of [WifiPasspointPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiPasspoint].
  static WifiPasspointPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiPasspointPlatform] when
  /// they register themselves.
  static set instance(WifiPasspointPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
