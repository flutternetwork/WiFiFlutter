library wifi_rtt;

import 'dart:async';

import 'package:flutter/services.dart';

part 'src/error.dart';

part 'src/result.dart';

part 'src/device.dart';

/// The `wifi_rtt` plugin entry point.
///
/// To get a new instance, call [WiFiRTT.instance].
class WiFiRTT {
  WiFiRTT._();

  /// Singleton instance of [WiFiRTT].
  static final instance = WiFiRTT._();

  final _channel = const MethodChannel('wifi_rtt');

  Future<bool> hasSupport() async {
    final hasSupport = await _channel.invokeMethod<bool>("hasSupport");
    return hasSupport!;
  }

  Future<Result<List<WiFiRangingResult>, RangingErrors>> startRanging(
      List<WiFiRangingDevice> devices,
      {bool askPermissions = true}) async {
    final map = await _channel.invokeMapMethod("startRanging", {
      "askPermissions": askPermissions,
      "devices": devices.map((device) => device._map).toList(),
    });
    // check if any error - return Result._error if any
    final errorCode = map!["error"];
    if (errorCode != null) {
      return Result._error(_deserializeRangingError(errorCode));
    }
    // parse and return list of RangingResult
    return Result._value(List<WiFiRangingResult>.unmodifiable(
        map["value"].map((map) => WiFiRangingResult._fromMap(map))));
  }
}