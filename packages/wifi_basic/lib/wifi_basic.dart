import 'dart:async';

import 'package:flutter/services.dart';

class WiFiBasic {
  static const instance = WiFiBasic._();
  final MethodChannel _channel;

  const WiFiBasic._() : _channel = const MethodChannel('wifi_basic');

  Future<bool> isSupported() async =>
      await _channel.invokeMethod('isSupported');

  Future<bool> isEnabled() async => await _channel.invokeMethod('isEnabled');

  Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod('setEnabled', {"enabled": enabled});

  Future<void> openSettings() async =>
      await _channel.invokeMethod("openSettings");
}
