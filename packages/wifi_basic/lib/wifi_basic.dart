import 'dart:async';

import 'package:flutter/services.dart';

class WiFiBasic {
  static const MethodChannel _channel = MethodChannel('wifi_basic');

  static Future<bool> isSupported() async =>
      await _channel.invokeMethod('isSupported');

  static Future<bool> isEnabled() async =>
      await _channel.invokeMethod('isEnabled');

  static Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod('setEnabled', {"enabled": enabled});

  static Future<void> openSettings() async =>
      await _channel.invokeMethod("openSettings");
}
