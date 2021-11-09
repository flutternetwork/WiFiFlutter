<p align="center">  
  <img width="360px" src="logo/logo+name_color.png"> <br /><br />
  <span>A suite of Flutter plugins that enable Flutter apps to use various WiFi services.</span>
</p>

## Plugins
| Plugin | pub.dev | Description  | Package quality| Android | iOS |
|:------:|:-------:|:------------:|:--------------:|:-------:|:---:|
| [`wifi_iot` (Legacy)][iot_code] | [![wifi_iot][iot_badge_pub]][iot_pub] | Plugin which can handle WiFi connections (AP, STA). <br/><br/> <blockquote>**This plugin is only maintained for legacy reasons. Kindly switch to other plugins from this suite.**</blockquote> | **Stable** | ✔️ | ✔️ *[<sub>[1]</sub>](#note)* |
| [`wifi_basic`][basic_code] | [![wifi_basic][basic_badge_pub]][basic_pub] | Provides basic WiFi information and functionalities, like - current network information, check WiFi enabled, enable/disable WiFi, etc.  | **`Not Implemented`** | ✔️ | ✔️ *[<sub>[2]</sub>](#note)* |
| [`wifi_scan`][scan_code] | [![wifi_scan][scan_badge_pub]][scan_pub] | Request scanning for WiFi networks and get scanned or cached results. | **`Not Implemented`** | ✔️ | ❌ |
| [`wifi_sta`][sta_code] | [![wifi_sta][sta_badge_pub]][sta_pub] | Connect or disconnect device to a traditional WiFi networks. | **`Not Implemented`** | ✔️ | ✔️ |
| [`wifi_ap`][ap_code] | [![wifi_ap][ap_badge_pub]][ap_pub] | Setup device as a WiFi access point (hotspot). | **`Not Implemented`** | ✔️ | ❌ |
| [`wifi_aware`][aware_code] | [![wifi_aware][aware_badge_pub]][aware_pub] | Discover and connect directly to nearby devices without any other type of connectivity between them. This method is [more decenteralized][aware_direct_differences] than WiFi Direct(P2P). Check [official docs][aware_official_docs] to read more about Wi-Fi Aware (Neighbor Awareness Networking or NAN). | **`Not Implemented`** | ✔️ | ❌ |
| [`wifi_rtt`][rtt_code] | [![wifi_rtt][rtt_badge_pub]][rtt_pub] | Measure the distance to nearby RTT-capable Wi-Fi access points and peer Wi-Fi Aware devices. Check [IEEE_802.11mc][rtt_wikipedia] Wikipedia page to read more about it. | **`Not Implemented`** | ✔️ | ❌ |

#### Note
  1. Only supports STA mode. 
  2. Only supports getting current network info.


[iot_pub]: https://pub.dev/packages/wifi_iot
[iot_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_iot
[iot_badge_pub]: https://img.shields.io/pub/v/wifi_iot.svg

[basic_pub]: https://pub.dev/packages/wifi_basic
[basic_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_basic
[basic_badge_pub]: https://img.shields.io/pub/v/wifi_basic.svg

[scan_pub]: https://pub.dev/packages/wifi_scan
[scan_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_scan
[scan_badge_pub]: https://img.shields.io/pub/v/wifi_scan.svg

[sta_pub]: https://pub.dev/packages/wifi_sta
[sta_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_sta
[sta_badge_pub]: https://img.shields.io/pub/v/wifi_sta.svg

[ap_pub]: https://pub.dev/packages/wifi_ap
[ap_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_ap
[ap_badge_pub]: https://img.shields.io/pub/v/wifi_ap.svg

[aware_pub]: https://pub.dev/packages/wifi_aware
[aware_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_aware
[aware_badge_pub]: https://img.shields.io/pub/v/wifi_aware.svg
[aware_official_docs]: https://www.wi-fi.org/discover-wi-fi/wi-fi-aware
[aware_direct_differences]: https://www.wi-fi.org/knowledge-center/faq/what-is-the-relationship-between-wi-fi-aware-and-wi-fi-direct

[rtt_pub]: https://pub.dev/packages/wifi_rtt
[rtt_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_rtt
[rtt_badge_pub]: https://img.shields.io/pub/v/wifi_rtt.svg
[rtt_wikipedia]: https://en.wikipedia.org/wiki/IEEE_802.11mc