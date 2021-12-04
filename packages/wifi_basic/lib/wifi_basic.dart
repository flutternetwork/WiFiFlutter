import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:wifi_basic/src/extensions.dart';

enum WiFiGenerations { unknown, legacy, wifi4, wifi5, wifi6 }

enum WiFiNetworkSecurity { unknown, none, wep, wpa, wpa2, wpa3 }

class WiFiInfo {
  final String ssid;
  final String bssid;
  final WiFiNetworkSecurity security;
  final bool isHidden;
  final int rssi;
  final double signalStrength;
  final bool hasInternet;
  final WiFiGenerations generation;

  bool get isNull => ssid.isEmpty;

  WiFiInfo._fromMap(Map map)
      : ssid = map["ssid"],
        bssid = map["bssid"],
        security = (map["security"] as int?).toWifiNetworkSecurity(),
        isHidden = map["isHidden"],
        rssi = map["rssi"],
        signalStrength = map["signalStrength"],
        hasInternet = map["hasInternet"],
        generation = (map["generation"] as int?).toWifiGeneration();

  @override
  String toString() => "ssid; $ssid; bssid: $bssid; security: $security; "
      "isHidden: $isHidden; rssi: $rssi; signalStrength: $signalStrength; "
      "hasInternet: $hasInternet; generation: $generation";
}

class WiFiBasic {
  WiFiBasic._();

  static final instance = WiFiBasic._();
  final MethodChannel _channel = const MethodChannel('wifi_basic');
  final _isSupportedMemo = AsyncMemoizer<bool>();
  final _getGenerationMemo = AsyncMemoizer<WiFiGenerations>();

  Future<bool> isSupported() => _isSupportedMemo
      .runOnce(() async => await _channel.invokeMethod('isSupported'));

  Future<WiFiGenerations> getGeneration() => _getGenerationMemo.runOnce(
      () async => (await _channel.invokeMethod("getGeneration") as int?)
          .toWifiGeneration());

  Future<bool> isEnabled() async => await _channel.invokeMethod('isEnabled');

  Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod('setEnabled', {"enabled": enabled});

  Future<void> openSettings() async =>
      await _channel.invokeMethod("openSettings");

  Future<WiFiInfo> getCurrentInfo() async =>
      WiFiInfo._fromMap(await _channel.invokeMapMethod("getCurrentInfo") ?? {});
}
