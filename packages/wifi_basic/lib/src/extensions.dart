import 'package:wifi_basic/wifi_basic.dart';

extension WiFiGenerationsExtension on WiFiGenerations {
  static WiFiGenerations fromInt(int? value) {
    switch (value) {
      case 0:
      case 1:
      case 2:
      case 3:
        return WiFiGenerations.legacy;
      case 4:
        return WiFiGenerations.wifi4;
      case 5:
        return WiFiGenerations.wifi5;
      case 6:
        return WiFiGenerations.wifi6;
      default:
        return WiFiGenerations.unknown;
    }
  }
}

extension WiFiNetworkSecurityExtension on WiFiNetworkSecurity {
  static WiFiNetworkSecurity fromInt(int? value) {
    switch (value) {
      case 0:
        return WiFiNetworkSecurity.unknown;
      case 1:
        return WiFiNetworkSecurity.none;
      case 2:
        return WiFiNetworkSecurity.wep;
      case 3:
        return WiFiNetworkSecurity.wpa;
      case 4:
        return WiFiNetworkSecurity.wpa2;
      case 5:
        return WiFiNetworkSecurity.wpa3;
      default:
        return WiFiNetworkSecurity.unknown;
    }
  }
}
