
import 'dart:async';

import 'package:flutter/services.dart';

class WifiBasic {
  static const MethodChannel _channel = MethodChannel('wifi_basic');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
