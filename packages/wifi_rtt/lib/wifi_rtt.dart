library wifi_rtt;

import 'dart:async';

import 'package:flutter/services.dart';

part 'src/can.dart';
part 'src/device.dart';
part 'src/result.dart';

/// The `wifi_rtt` plugin entry point.
///
/// To get a new instance, call [WiFiRTT.instance].
class WiFiRTT {
  WiFiRTT._();

  /// Singleton instance of [WiFiRTT].
  static final instance = WiFiRTT._();

  final _channel = const MethodChannel('wifi_rtt');

  Future<CanRequestRanging> canRequestRanging(
      {bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>("canRequestRanging", {
      "askPermissions": askPermissions,
    });
    return _deserializeCanRequestRanging(canCode);
  }

  Future<List<WiFiRangingResult>> requestRanging(
      List<WiFiRangingDevice> devices) async {
    final results = await _channel.invokeListMethod("requestRanging", {
      "devices": devices.map((device) => device._map).toList(),
    });
    // parse and return list of RangingResult
    return List<WiFiRangingResult>.unmodifiable(
        results!.map((map) => WiFiRangingResult._fromMap(map)));
  }
}
