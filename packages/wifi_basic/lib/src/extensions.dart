import 'package:wifi_basic/wifi_basic.dart';

extension ToEnumExtension on int? {
  WiFiGenerations toWifiGeneration() {
    if (this == null || this! < 0 || this! > 6) {
      return WiFiGenerations.unknown;
    }
    // legacy - if less than 3
    if (this! <= 3) return WiFiGenerations.legacy;
    // convert generationInt -> generationEnum
    return WiFiGenerations.values[this! - 2];
  }

  WiFiNetworkSecurity toWifiNetworkSecurity() {
    if (this == null ||
        this! < 0 ||
        this! > WiFiNetworkSecurity.values.length) {
      return WiFiNetworkSecurity.unknown;
    }
    return WiFiNetworkSecurity.values[this! + 1];
  }
}
