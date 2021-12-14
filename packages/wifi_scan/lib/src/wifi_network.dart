part of '../../wifi_scan.dart';

// TODO
enum WiFiStandards { unkown, legacy }

WiFiStandards _deserializeWiFiStandards(int? standardCode) {
  return WiFiStandards.unkown;
}

class WiFiNetwork {
  final String ssid;
  final String bssid;
  final String capabilities;
  final int frequency;
  final int level;
  final int? timestamp;
  final WiFiStandards standard;
  final int? centerFrequency0;
  final int? centerFrequency1;
  final int? channelWidth;
  final bool? isPasspoint;
  final String? operatorFriendlyName;
  final String? venueName;
  final bool? is80211mcResponder;

  WiFiNetwork._fromMap(Map map)
      : ssid = map["ssid"],
        bssid = map["bssid"],
        capabilities = map["capabilities"],
        frequency = map["frequency"],
        level = map["level"],
        timestamp = map["timestamp"],
        standard = _deserializeWiFiStandards(map["standard"]),
        centerFrequency0 = map["centerFrequency0"],
        centerFrequency1 = map["centerFrequency1"],
        channelWidth = map["channelWidth"],
        isPasspoint = map["isPasspoint"],
        operatorFriendlyName = map["operatorFriendlyName"],
        venueName = map["venueName"],
        is80211mcResponder = map["is80211mcResponder"];
}
