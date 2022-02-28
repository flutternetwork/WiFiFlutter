<a href="https://wifi.flutternetwork.dev">
  <p align="center">  
    <img width="360px" src="logo/logo+name_color.png">
  </p>
</a>

<p align="center">
  <a href="https://github.com/flutternetwork/WiFiFlutter/actions?query=workflow%3Aall_plugins">
    <img src="https://github.com/flutternetwork/WiFiFlutter/workflows/all_plugins/badge.svg" alt="all_plugins GitHub Workflow Status"/>
  </a>
  <a href="https://codecov.io/gh/flutternetwork/WiFiFlutter/">
    <img src="https://codecov.io/gh/flutternetwork/WiFiFlutter/graph/badge.svg" alt="all_plugins Coverage"/>
  </a>
  <a href="https://gitter.im/flutternetwork/WiFiFlutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
    <img src="https://badges.gitter.im/flutternetwork/WiFiFlutter.svg" alt="Join the chat at https://gitter.im/flutternetwork/WiFiFlutter]">
  </a>
  <a href="https://github.com/invertase/melos#readme-badge">
    <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg" alt="Melos" />
  </a>
</p>

---

WiFiFlutter is a suite of Flutter plugins that enable Flutter apps to use various WiFi services.

> *Note*: WiFiFlutter is going under [reforms](https://github.com/flutternetwork/WiFiFlutter/discussions/229), therefore some plugins might not be available yet. [Feedback](https://github.com/flutternetwork/WiFiFlutter/issues) and [Pull Requests](https://github.com/flutternetwork/WiFiFlutter/pulls) are most welcome!

## Plugins

**Table of contents:**

- [For IoT (`wifi_iot`)](#wifi_iot)
<!-- HIDING until available
- [Basic (`wifi_basic`)](#wifi_basic)
-->
- [Scan (`wifi_scan`)](#wifi_scan)
<!--
- [Station (`wifi_sta`)](#wifi_sta)
- [Access Point / Hotspot (`wifi_ap`)](#wifi_ap)
- [Aware (`wifi_aware`)](#wifi_aware)
- [Location / RTT  (`wifi_rtt`)](#wifi_rtt)
-->

---

### `wifi_iot`
> [![wifi_iot][iot_workflow_badge]][iot_workflow] [![wifi_iot][iot_pub_badge]][iot_pub] [![pub points][iot_pub_points_badge]][iot_pub_points]

Flutter plugin which can handle WiFi connections (AP, STA).
<!--  HIDING until other plugins available > This plugin is only maintained for legacy reasons. Kindly switch to other alternate plugins from this suite. -->

[[View Source][iot_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ✔️    |  ✔️* |

<sub>*Only supports STA mode.</sub>

---

<!-- HIDING until available
### `wifi_basic`
> [![wifi_basic][basic_workflow_badge]][basic_workflow] [![wifi_basic][basic_pub_badge]][basic_pub] [![pub points][basic_pub_points_badge]][basic_pub_points]

Flutter plugin for basic WiFi information and functionalities.

[[View Source][basic_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ❌* |

<sub>*Only supports getting network info.</sub>

---
-->

### `wifi_scan`
> [![wifi_scan][scan_workflow_badge]][scan_workflow] [![wifi_scan][scan_pub_badge]][scan_pub] [![pub points][scan_pub_points_badge]][scan_pub_points]

Flutter plugin to scan for nearby visible WiFi access points.

[[View Source][scan_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|   ✔️    |     |

---

<!-- HIDING until available
### `wifi_sta`
> [![wifi_sta][sta_workflow_badge]][sta_workflow] [![wifi_sta][sta_pub_badge]][sta_pub] [![pub points][sta_pub_points_badge]][sta_pub_points]

Flutter plugin to connect or disconnect device to a traditional WiFi network.

[[View Source][sta_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ❌  |

---

### `wifi_ap`
> [![wifi_ap][ap_workflow_badge]][ap_workflow] [![wifi_ap][ap_pub_badge]][ap_pub] [![pub points][ap_pub_points_badge]][ap_pub_points]

Flutter plugin to setup device as a WiFi access point (hotspot).

[[View Source][ap_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---

### `wifi_aware`
> [![wifi_aware][aware_workflow_badge]][aware_workflow] [![wifi_aware][aware_pub_badge]][aware_pub] [![pub points][aware_pub_points_badge]][aware_pub_points]

Flutter plugin to discover and connect directly to nearby devices without any other type of connectivity between them.
> This method is [more decenteralized][aware_direct_differences] than WiFi Direct(P2P). Check [official docs][aware_official_docs] to read more about Wi-Fi Aware (Neighbor Awareness Networking or NAN).

[[View Source][aware_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---

### `wifi_rtt`
> [![wifi_rtt][rtt_workflow_badge]][rtt_workflow] [![wifi_rtt][rtt_pub_badge]][rtt_pub] [![pub points][rtt_pub_points_badge]][rtt_pub_points]

Flutter plugin to measure the distance to nearby RTT-capable Wi-Fi access points and peer Wi-Fi Aware devices. 
> Check [IEEE_802.11mc][rtt_wikipedia] Wikipedia page to read more about it.

[[View Source][rtt_code]]

#### Platform Support
| Android | iOS |
| :-----: | :-: |
|    ❌    |  ➖ |

---
-->

## Issues

Please file WiFiFlutter specific issues, bugs, or feature requests in our [issue tracker](https://github.com/flutternetwork/WiFiFlutter/issues/new).

Plugin issues that are not specific to WiFiFlutter can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/flutternetwork/WiFiFlutter/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/flutternetwork/WiFiFlutter/pulls).

## Status

This repository is maintained by WiFiFlutter authors. Issues here are answered by maintainers and other community members on GitHub on a best-effort basis.

<!-- links -->
[iot_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_iot
[iot_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml
[iot_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml/badge.svg
[iot_pub]: https://pub.dev/packages/wifi_iot
[iot_pub_badge]: https://img.shields.io/pub/v/wifi_iot.svg
[iot_pub_points]: https://pub.dev/packages/wifi_iot/score
[iot_pub_points_badge]: https://badges.bar/wifi_iot/pub%20points

[basic_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_basic
[basic_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_basic.yaml
[basic_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_basic.yaml/badge.svg
[basic_pub]: https://pub.dev/packages/wifi_basic
[basic_pub_badge]: https://img.shields.io/pub/v/wifi_basic.svg
[basic_pub_points]: https://pub.dev/packages/wifi_basic/score
[basic_pub_points_badge]: https://badges.bar/wifi_basic/pub%20points

[scan_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_scan
[scan_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_scan.yaml
[scan_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_scan.yaml/badge.svg
[scan_pub]: https://pub.dev/packages/wifi_scan
[scan_pub_badge]: https://img.shields.io/pub/v/wifi_scan.svg
[scan_pub_points]: https://pub.dev/packages/wifi_scan/score
[scan_pub_points_badge]: https://badges.bar/wifi_scan/pub%20points

[sta_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_sta
[sta_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_sta.yaml
[sta_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_sta.yaml/badge.svg
[sta_pub]: https://pub.dev/packages/wifi_sta
[sta_pub_badge]: https://img.shields.io/pub/v/wifi_sta.svg
[sta_pub_points]: https://pub.dev/packages/wifi_sta/score
[sta_pub_points_badge]: https://badges.bar/wifi_sta/pub%20points

[ap_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_ap
[ap_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_ap.yaml
[ap_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_ap.yaml/badge.svg
[ap_pub]: https://pub.dev/packages/wifi_ap
[ap_pub_badge]: https://img.shields.io/pub/v/wifi_ap.svg
[ap_pub_points]: https://pub.dev/packages/wifi_ap/score
[ap_pub_points_badge]: https://badges.bar/wifi_ap/pub%20points

[aware_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_aware
[aware_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_aware.yaml
[aware_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_aware.yaml/badge.svg
[aware_pub]: https://pub.dev/packages/wifi_aware
[aware_pub_badge]: https://img.shields.io/pub/v/wifi_aware.svg
[aware_pub_points]: https://pub.dev/packages/wifi_aware/score
[aware_pub_points_badge]: https://badges.bar/wifi_aware/pub%20points
[aware_official_docs]: https://www.wi-fi.org/discover-wi-fi/wi-fi-aware
[aware_direct_differences]: https://www.wi-fi.org/knowledge-center/faq/what-is-the-relationship-between-wi-fi-aware-and-wi-fi-direct

[rtt_code]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_rtt
[rtt_workflow]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_rtt.yaml
[rtt_workflow_badge]: https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_rtt.yaml/badge.svg
[rtt_pub]: https://pub.dev/packages/wifi_rtt
[rtt_pub_badge]: https://img.shields.io/pub/v/wifi_rtt.svg
[rtt_pub_points]: https://pub.dev/packages/wifi_rtt/score
[rtt_pub_points_badge]: https://badges.bar/wifi_rtt/pub%20points
[rtt_wikipedia]: https://en.wikipedia.org/wiki/IEEE_802.11mc
