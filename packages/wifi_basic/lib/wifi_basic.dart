import 'dart:async';

import 'package:flutter/services.dart';

class WiFiBasic {
  static const MethodChannel _channel = MethodChannel('wifi_basic');

  static Future<bool> hasCapability() async =>
      await _channel.invokeMethod('hasCapability');

  static Future<bool> isEnabled() async =>
      await _channel.invokeMethod('isEnabled');

  static Future<bool> setEnabled(bool enabled,
          {bool shouldOpenSettings = false}) async =>
      await _channel.invokeMethod('setEnabled', {
        "enabled": enabled,
        "shouldOpenSettings": shouldOpenSettings,
      });
}
