part of 'wifi_basic.dart';

class WiFiInfo {
  static const Equality _equality = DeepCollectionEquality();

  final String ssid;
  final String bssid;
  final WiFiNetworkSecurity security;
  final bool isHidden;
  final int rssi;
  final double signalStrength;
  final bool hasInternet;
  final WiFiGenerations generation;

  bool get isNull => ssid.isEmpty;

  @visibleForTesting
  WiFiInfo.fromMap(Map map)
      : ssid = map["ssid"] as String,
        bssid = map["bssid"] as String,
        security =
            WiFiNetworkSecurityExtension.fromInt(map["security"] as int?),
        isHidden = map["isHidden"] as bool,
        rssi = map["rssi"] as int,
        signalStrength = map["signalStrength"] as double,
        hasInternet = map["hasInternet"] as bool,
        generation =
            WiFiGenerationsExtension.fromInt(map["generation"] as int?);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          other is WiFiInfo &&
          _equality.equals(ssid, other.ssid) &&
          _equality.equals(bssid, other.bssid) &&
          _equality.equals(security, other.security) &&
          _equality.equals(isHidden, other.isHidden) &&
          _equality.equals(rssi, other.rssi) &&
          _equality.equals(signalStrength, other.signalStrength) &&
          _equality.equals(hasInternet, other.hasInternet) &&
          _equality.equals(generation, other.generation));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        _equality.hash(ssid),
        _equality.hash(bssid),
        _equality.hash(security),
        _equality.hash(isHidden),
        _equality.hash(rssi),
        _equality.hash(signalStrength),
        _equality.hash(hasInternet),
        _equality.hash(generation),
      );

  @override
  String toString() => "WiFiInfo(ssid: $ssid, bssid: $bssid, "
      "security: $security, isHidden: $isHidden, rssi: $rssi, "
      "signalStrength: $signalStrength, hasInternet: $hasInternet, "
      "generation: $generation)";
}
