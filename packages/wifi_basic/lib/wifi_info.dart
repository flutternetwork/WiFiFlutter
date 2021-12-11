part of 'wifi_basic.dart';

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
