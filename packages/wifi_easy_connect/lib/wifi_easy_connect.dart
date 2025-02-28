library wifi_easy_connect;

import 'package:flutter/services.dart';

part 'src/capability.dart';
part 'src/error.dart';

/// The `wifi_easy_connect` plugin entry point.
///
/// To get a new instance, call [WiFiEasyConnect.instance].
class WiFiEasyConnect {
  WiFiEasyConnect._();

  /// Singleton instance of [WiFiEasyConnect].
  static final instance = WiFiEasyConnect._();

  final _channel = const MethodChannel('wifi_easy_connect');

  /// Check if supports Wi-Fi Easy connect (Device Provisioning Protocol).
  ///
  /// Returns [WiFiEasyConnectCapability] value.
  Future<WiFiEasyConnectCapability> hasCapability() async {
    final capabilityCode = await _channel.invokeMethod<int>("hasCapability");
    return _deserializeCapability(capabilityCode!);
  }

  /// Onboard a device to join network via Wi-Fi Easy Connect (DPP).
  ///
  /// TODO: more info about args and return value.
  Future<OnboardError?> onboard(Uri dppUri, {List<int>? bands}) async {
    assert(dppUri.scheme.toUpperCase() == "DPP", "Valid scheme for DPP URI");

    final map = await _channel.invokeMapMethod("onboard", {
      "dppUri": dppUri.toString(),
      "bands": bands,
    });

    // check if any error - return OnboardError
    if (map?.containsKey("error") ?? false) {
      return OnboardError._fromMap(map!);
    }

    return null;
  }
}
