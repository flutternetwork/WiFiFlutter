import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wifi_connect_to_method_channel.dart';

abstract class WifiConnectToPlatform extends PlatformInterface {
  /// Constructs a WifiConnectToPlatform.
  WifiConnectToPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiConnectToPlatform _instance = MethodChannelWifiConnectTo();

  /// The default instance of [WifiConnectToPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiConnectTo].
  static WifiConnectToPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiConnectToPlatform] when
  /// they register themselves.
  static set instance(WifiConnectToPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
