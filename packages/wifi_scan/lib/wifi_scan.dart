import 'dart:async';

import 'package:flutter/services.dart';

class WiFiScan {
  WiFiScan._();

  static final instance = WiFiScan._();
  final MethodChannel _channel = const MethodChannel('wifi_scan');

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
