part of '../wifi_scan.dart';

/// WiFi standards.
enum WiFiStandards {
  /// Unknown.
  unkown,

  /// [Wi-Fi 802.11a/b/g](https://en.wikipedia.org/wiki/IEEE_802.11).
  legacy,

  /// [Wi-Fi 802.11n (Wi-Fi 4)](https://en.wikipedia.org/wiki/IEEE_802.11n).
  n,

  /// [Wi-Fi 802.11ac (Wi-Fi 5)](https://en.wikipedia.org/wiki/IEEE_802.11ac).
  ac,

  /// [Wi-Fi 802.11ax (Wi-Fi 6)](https://en.wikipedia.org/wiki/IEEE_802.11ax).
  ax,

  /// [Wi-Fi 802.11ad](https://en.wikipedia.org/wiki/IEEE_802.11ad).
  ad,
}

WiFiStandards _deserializeWiFiStandards(int? standardCode) {
  switch (standardCode) {
    case 1:
      return WiFiStandards.legacy;
    case 4:
      return WiFiStandards.n;
    case 5:
      return WiFiStandards.ac;
    case 6:
      return WiFiStandards.ax;
    case 7:
      return WiFiStandards.ad;
    default:
      return WiFiStandards.unkown;
  }
}

/// Channel bandwidth supported by WiFi.
enum WiFiChannelWidth {
  /// Unknown.
  unkown,

  /// 20 MHZ.
  mhz20,

  /// 40 MHZ.
  mhz40,

  /// 40 MHZ.
  mhz80,

  /// 160 MHZ.
  mhz160,

  /// 160 MHZ, but 80MHZ + 80MHZ.
  mhz80Plus80,
}

WiFiChannelWidth _deserializeWiFiChannelWidth(int? channelWidthCode) {
  switch (channelWidthCode) {
    case 0:
      return WiFiChannelWidth.mhz20;
    case 1:
      return WiFiChannelWidth.mhz40;
    case 2:
      return WiFiChannelWidth.mhz80;
    case 3:
      return WiFiChannelWidth.mhz160;
    case 4:
      return WiFiChannelWidth.mhz80Plus80;
    default:
      return WiFiChannelWidth.unkown;
  }
}

/// Describes information about a detected access point.
class WiFiAccessPoint {
  /// The network name.
  final String ssid;

  /// The address of the access point.
  final String bssid;

  /// Describes authentication and other schemes supported by the access point.
  // TODO: parse this for proper enums for - security
  final String capabilities;

  /// WiFi standard supported by the access poit.
  final WiFiStandards standard;

  /// The detected signal strength in dBm, also known as the RSSI.
  ///
  /// The value is in negative integer, the greater the value, the stronger the
  /// signal. The closer the value is to 0, the stronger the received signal
  /// has been.
  ///
  /// Following data can be used to determine signal quality:
  /// -30 dBm = Excellent
  /// -67 dBm = Very Good
  /// -70 dBm = Okay
  /// -80 dBm = Not Good
  /// -90 dBm = Unusable
  /// For more info - https://www.securedgenetworks.com/blog/wifi-signal-strength.
  // TODO: rename to rssi or signalStrength - and give additional enum for level
  final int level;

  /// Channel bandwidth of the access point.
  final WiFiChannelWidth? channelWidth;

  /// The primary 20MHz frequency of the channel over which the client is
  /// communicating with the AP.
  ///
  /// The value is in MHz.
  final int frequency;

  /// Center frequency of the access point.
  ///
  /// For [WiFiChannelWidth.mhz20] bandwidth, it is null.
  /// For [WiFiChannelWidth.mhz80Plus80] bandwidth, it is the center frequency
  /// of the first segment.
  final int? centerFrequency0;

  /// Center frequency of the access point.
  ///
  /// Only used for [WiFiChannelWidth.mhz80Plus80] bandwidth, it is the center
  /// frequency of the secod segment.
  final int? centerFrequency1;

  /// Timestamp in microseconds (since boot) when this result was last seen.
  final int? timestamp;

  /// Indicates if the access point is a Passpoint (Hotspot 2.0).
  final bool? isPasspoint;

  /// Indicates Passpoint operator name published by access point.
  final String? operatorFriendlyName;

  /// Indicates venue name published by access point.
  ///
  /// Only available on Passpoint network and if published by access point.
  final String? venueName;

  /// Indicates if the access point can respond to
  /// [IEEE 802.11mc (WiFi RTT)](https://en.wikipedia.org/wiki/IEEE_802.11mc)
  /// ranging requests.
  final bool? is80211mcResponder;

  /// build WiFiAccessPoint property
  WiFiAccessPoint.fromMap(Map map)
      : ssid = map["ssid"],
        bssid = map["bssid"],
        capabilities = map["capabilities"],
        frequency = map["frequency"],
        level = map["level"],
        timestamp = map["timestamp"],
        standard = _deserializeWiFiStandards(map["standard"]),
        centerFrequency0 = map["centerFrequency0"],
        centerFrequency1 = map["centerFrequency1"],
        channelWidth = _deserializeWiFiChannelWidth(map["channelWidth"]),
        isPasspoint = map["isPasspoint"],
        operatorFriendlyName = map["operatorFriendlyName"],
        venueName = map["venueName"],
        is80211mcResponder = map["is80211mcResponder"];
}
