
import 'dart:async';

import 'package:flutter/services.dart';

class WifiEasyConnect {
  static const MethodChannel _channel = MethodChannel('wifi_easy_connect');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
