<a href="https://wifi.flutternetwork.dev">
  <p align="center">  
    <img width="360px" src="logo/logo+name_color.png">
  </p>
</a>

<p align="center">
  <a href="https://github.com/invertase/melos#readme-badge"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Melos" /></a>
</p>

---

WiFiFlutter is a suite of Flutter plugins that enable Flutter apps to use various WiFi services.

[Feedback](https://github.com/alternadom/WiFiFlutter/issues) and [Pull Requests](https://github.com/alternadom/WiFiFlutter/pulls) are most welcome!

## Plugins

**Table of contents:**

- [IoT *(Legacy)* (`wifi_iot`)](#wifi_iot)
- [Basic (`wifi_basic`)](#wifi_basic)
- [Scan (`wifi_scan`)](#wifi_scan)
- [Station (`wifi_sta`)](#wifi_sta)
- [Access Point / Hotspot (`wifi_ap`)](#wifi_ap)
- [Aware (`wifi_aware`)](#wifi_aware)
- [Location/RTT  (`wifi_rtt`)](#wifi_rtt)

---

### `wifi_iot`
> [![wifi_iot][iot_badge_pub]][iot_pub] [![pub points][iot_badge_pub_points]][iot_pub_points]

Flutter plugin which can handle WiFi connections (AP, STA).
> This plugin is only maintained for legacy reasons. Kindly switch to other alternate plugins from this suite.

[[View Source][iot_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|   ❌    |  ❌* |

<sub>*Only supports STA mode.</sub>

---

### `wifi_basic`
> [![wifi_basic][basic_badge_pub]][basic_pub] [![pub points][basic_badge_pub_points]][basic_pub_points]

Flutter plugin for basic WiFi information and functionalities.

[[View Source][basic_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ❌* |

<sub>*Only supports getting network info.</sub>

---

### `wifi_scan`
> [![wifi_scan][scan_badge_pub]][scan_pub] [![pub points][scan_badge_pub_points]][scan_pub_points]

Flutter plugin to scan for WiFi networks.

[[View Source][scan_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    | ➖  |

---

### `wifi_sta`
> [![wifi_sta][sta_badge_pub]][sta_pub] [![pub points][sta_badge_pub_points]][sta_pub_points]

Flutter plugin to connect or disconnect device to a traditional WiFi network.

[[View Source][sta_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ❌  |

---

### `wifi_ap`
> [![wifi_ap][ap_badge_pub]][ap_pub] [![pub points][ap_badge_pub_points]][ap_pub_points]

Flutter plugin to setup device as a WiFi access point (hotspot).

[[View Source][ap_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---

### `wifi_aware`
> [![wifi_aware][aware_badge_pub]][aware_pub] [![pub points][aware_badge_pub_points]][aware_pub_points]

Flutter plugin to discover and connect directly to nearby devices without any other type of connectivity between them.
> This method is [more decenteralized][aware_direct_differences] than WiFi Direct(P2P). Check [official docs][aware_official_docs] to read more about Wi-Fi Aware (Neighbor Awareness Networking or NAN).

[[View Source][aware_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---

### `wifi_rtt`
> [![wifi_rtt][rtt_badge_pub]][rtt_pub] [![pub points][rtt_badge_pub_points]][rtt_pub_points]

Flutter plugin to measure the distance to nearby RTT-capable Wi-Fi access points and peer Wi-Fi Aware devices. 
> Check [IEEE_802.11mc][rtt_wikipedia] Wikipedia page to read more about it.

[[View Source][rtt_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---

## Issues

Please file WiFiFlutter specific issues, bugs, or feature requests in our [issue tracker](https://github.com/alternadom/WiFiFlutter/issues/new).

Plugin issues that are not specific to WiFiFlutter can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/alternadom/WiFiFlutter/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/alternadom/WiFiFlutter/pulls).

## Status

This repository is maintained by WiFiFlutter authors. Issues here are answered by maintainers and other community members on GitHub on a best-effort basis.

<!-- links -->
[iot_pub]: https://pub.dev/packages/wifi_iot
[iot_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_iot
[iot_badge_pub]: https://img.shields.io/pub/v/wifi_iot.svg
[iot_badge_pub_points]: https://badges.bar/wifi_iot/pub%20points
[iot_pub_points]: https://pub.dev/packages/wifi_iot/score

[basic_pub]: https://pub.dev/packages/wifi_basic
[basic_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_basic
[basic_badge_pub]: https://img.shields.io/pub/v/wifi_basic.svg
[basic_badge_pub_points]: https://badges.bar/wifi_basic/pub%20points
[basic_pub_points]: https://pub.dev/packages/wifi_basic/score

[scan_pub]: https://pub.dev/packages/wifi_scan
[scan_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_scan
[scan_badge_pub]: https://img.shields.io/pub/v/wifi_scan.svg
[scan_badge_pub_points]: https://badges.bar/wifi_scan/pub%20points
[scan_pub_points]: https://pub.dev/packages/wifi_scan/score

[sta_pub]: https://pub.dev/packages/wifi_sta
[sta_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_sta
[sta_badge_pub]: https://img.shields.io/pub/v/wifi_sta.svg
[sta_badge_pub_points]: https://badges.bar/wifi_sta/pub%20points
[sta_pub_points]: https://pub.dev/packages/wifi_sta/score

[ap_pub]: https://pub.dev/packages/wifi_ap
[ap_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_ap
[ap_badge_pub]: https://img.shields.io/pub/v/wifi_ap.svg
[ap_badge_pub_points]: https://badges.bar/wifi_ap/pub%20points
[ap_pub_points]: https://pub.dev/packages/wifi_ap/score

[aware_pub]: https://pub.dev/packages/wifi_aware
[aware_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_aware
[aware_badge_pub]: https://img.shields.io/pub/v/wifi_aware.svg
[aware_badge_pub_points]: https://badges.bar/wifi_aware/pub%20points
[aware_pub_points]: https://pub.dev/packages/wifi_aware/score
[aware_official_docs]: https://www.wi-fi.org/discover-wi-fi/wi-fi-aware
[aware_direct_differences]: https://www.wi-fi.org/knowledge-center/faq/what-is-the-relationship-between-wi-fi-aware-and-wi-fi-direct

[rtt_pub]: https://pub.dev/packages/wifi_rtt
[rtt_code]: https://github.com/alternadom/WiFiFlutter/tree/master/packages/wifi_rtt
[rtt_badge_pub]: https://img.shields.io/pub/v/wifi_rtt.svg
[rtt_badge_pub_points]: https://badges.bar/wifi_rtt/pub%20points
[rtt_pub_points]: https://pub.dev/packages/wifi_rtt/score
[rtt_wikipedia]: https://en.wikipedia.org/wiki/IEEE_802.11mc
