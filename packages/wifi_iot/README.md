<h3><a href="https://wifi.flutternetwork.dev/" ><img src="https://raw.githubusercontent.com/flutternetwork/WiFiFlutter/master/logo/logo%2Bname_vertical_color.png" alt="WiFiFlutter" height="112"/></a>| <code>wifi_iot</code></h3>

<p>
<a href="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml"><img src="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml/badge.svg" alt="analysis"></a>
<a href="https://pub.dev/packages/wifi_iot"><img src="https://img.shields.io/pub/v/wifi_iot?logo=dart" alt="pub.dev"></a><!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
<a href="#contributors-"><img src="https://img.shields.io/badge/all_contributors-47-orange.svg" alt="All Contributors" /></a>
<!-- ALL-CONTRIBUTORS-BADGE:END -->
<a href="https://pub.dev/packages/wifi_iot/score"><img src="https://badges.bar/wifi_iot/pub%20points" alt="pub points"></a>
<a href="https://pub.dev/packages/wifi_iot/score"><img src="https://badges.bar/wifi_iot/popularity" alt="popularity"></a>
<a href="https://pub.dev/packages/wifi_iot/score"><img src="https://badges.bar/wifi_iot/likes" alt="likes"></a>
</p>

---

## Introduction

Plugin Flutter which can handle WiFi connections (AP, STA)

Becareful, some commands as no effect on iOS because Apple don't let us to do whatever we want...

## WiFi connections
|                      Description                      |      Android       |         iOS          |
| :---------------------------------------------------- | :----------------: | :------------------: |
| Enabling / Disabling WiFi module                      | :warning:(3a) |  :x:  |
| Getting WiFi status                                   | :white_check_mark: |  :x:  |
| Scanning for networks, with "already-associated" flag | :white_check_mark: |  :x:  |
| Connecting / Disconnecting on a network in WPA / WEP  | :white_check_mark:(3b) |  :white_check_mark:(1)  |
| Registering / Unregistering a WiFi network            | :white_check_mark:(3c) |  :warning:(2)  |
| Getting informations like :                           | :white_check_mark: |  :white_check_mark:  |
| - SSID                                                | :white_check_mark: |  :white_check_mark:  |
| - BSSID                                               | :white_check_mark: |  :white_check_mark:  |
| - Current signal strength                             | :white_check_mark: |  :x:  |
| - Frequency                                           | :white_check_mark: |  :x:  |
| - IP                                                  | :white_check_mark: |  :white_check_mark:  |

:white_check_mark:(1) : On iOS, you can only disconnect from a network which has been added by your app. In order to disconnect from a system network, you have to connect to an other!

:warning:(2) : On iOS, you can forget a WiFi network by connecting to it with the joinOnce flag to true!

:warning:(3): Wifi API changes in Android SDK >= 29, restricts certain behaviour:
  * a. Enable/Disable Wifi Module is deprecated and will always fail [[docs](https://developer.android.com/reference/android/net/wifi/WifiManager#setWifiEnabled(boolean))]. If you  want to open "Wifi Setting" in that case then, set the `shouldOpenSettings: true` when calling `setEnabled`.
  * b. Note for connecting to Wifi - 
    * (i) WEP security is deprecated and will always fail.
    * (ii) By default the connection would not have internet access and will be disconnected when the app is closed (if permanent network is required(Check :warning:(3c)), use "Register Network" feature) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-bootstrap))]. 
    * (iii) To connect to network with internet use `withInternet` which is a different API underneath (this API will not disconnect to network after app closes, therefore use `removeWifiNetwork` method to remove/disconnect network added in previous session) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-suggest)].
    * (iv) Will have to use `forceWifiUsage(true)` to route app traffic via connected access point, similarly can be disabled to route traffic via cellular network (for internet). This is not enabled by default and left upto to the user. 
  * c. Registering Wifi Network, will require user approval - and the network saved would not be controlled by the app (for deletion, updation, etc) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-save-network-passpoint-config)];

Additional Wifi protocols on Android side like - Wifi Direct, Wifi Aware, etc are in active discussion at [#140](https://github.com/flutternetwork/WiFiFlutter/issues/140). Encourage you to engage if you want this features.

## Access Point
|                                       Description                                     |      Android       |         iOS          |
| :------------------------------------------------------------------------------------ | :----------------: | :------------------: |
| Getting the status of the Access Point (Disable, disabling, enable, enabling, failed) | :warning:(1b) |  :x:  |
| Enabling / Disabling Access Point                                                     | :white_check_mark:(1c) |  :x:  |
| Getting / Setting new credentials (SSID / Password)                                   | :warning:(1b) |  :x:  |
| Enabling / Disabling the visibility of the SSID Access Point                          | :warning:(1a) |  :x:  |
| Getting the clients list (IP, BSSID, Device, Reachable)                               | :warning:(1a) |  :x:  |

:warning:(1): Wifi API changes in Android SDK 26 and 29, restricts certain behaviour:
  * a. This has been deprecated and will always fail for >= 26 Android SDK.
  * b. This has been deprecated and will always fail for >= 26 Android SDK. There is a way to make "get" methods work for >= 29 Android SDK, but is currently not implemented, request these features if you need them at [#134](https://github.com/flutternetwork/WiFiFlutter/issues/134).
  * c. Uses [`startLocalOnlyHotspot` API](https://developer.android.com/reference/android/net/wifi/WifiManager#startLocalOnlyHotspot(android.net.wifi.WifiManager.LocalOnlyHotspotCallback,%20android.os.Handler)) to request enabling or disabling WiFi AP for >= 29 Android SDK. This can only be used to communicate between co-located devices connected to the created WiFi Hotspot. Note - 
    * (i) Enabling and Disabling WiFi AP needs to request location permission.
    * (ii) The network created by this method will not have Internet access.
    * (iii) There's no way for the user to set WiFi AP's SSID and Passphrase, they are automatically generated by the OS.
    * (iv) This is actually a "request" and not a "command", as the `LocalOnlyHotspot` is shared (potentially) across applications and therefore a request to enable/disable may not not necessarily trigger the immediate execution of it. 

For now, there is no way to set the access point on iOS... 

## Xcode build (iOS >= 8.0)

To be able to build with Xcode, you must specify `use_frameworks!` in your Podfile to allow building Swift into static libraries.

<!---TODO: This a planned breaking change to happen in v1.0.0
## Android Permissions
The following permissions are listed according to their intended use:

### Required permissions added by the plugin (not need to add this explicitly in your project):
The physical WiFi module can be used with this feature.
```xml
<uses-feature android:name="android.hardware.wifi" />
```
Permission to use internet:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
Permission to access `WifiManager` API:
```xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```
Permission to access `ConnectivityManager` API. Useful for managing network state:
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```
Permission to use location as required to enable or disable WiFi AP:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
There's no need to add the permissions mentioned above to your project, since it's already been added to the plugin.
### Using WiFi only (need to add these explicitly in your project, if you use these functions)
Permission to enable or Disable WiFi:
```xml
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```
Permission to add WiFi networks:
```xml
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
```
### Using WiFi AP only (need to add this explicitly in your project, if you use these functions)
Permission to configure WiFi AP SSID and password:
```xml
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
```
--->

## Troubleshooting

Don't hesitate and come [here](https://github.com/flutternetwork/WiFiFlutter/issues), we will be happy to help you!

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://www.alternadom.com/"><img src="https://avatars.githubusercontent.com/u/14965352?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Florian</b></sub></a><br /><a href="#ideas-alternadom" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=alternadom" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=alternadom" title="Documentation">📖</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/example?author=alternadom" title="Examples">💡</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3Aalternadom" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/yhua537"><img src="https://avatars.githubusercontent.com/u/21363409?v=4?s=100" width="100px;" alt=""/><br /><sub><b>yhua537</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=yhua537" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/anharismail"><img src="https://avatars.githubusercontent.com/u/37614260?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Anhar Ismail</b></sub></a><br /><a href="https://dribbble.com/shots/10203130-WiFi-Flutter-Logo-Design" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/tristan2468"><img src="https://avatars.githubusercontent.com/u/776717?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Tristan Linnell</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Atristan2468" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://pboos.ch/"><img src="https://avatars.githubusercontent.com/u/398400?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Patrick Boos</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=pboos" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/example?author=pboos" title="Examples">💡</a></td>
    <td align="center"><a href="https://www.sfaye.com/"><img src="https://avatars.githubusercontent.com/u/14291522?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sébastien Faye</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=sfaye" title="Code">💻</a></td>
    <td align="center"><a href="https://ottomatic.io/"><img src="https://avatars.githubusercontent.com/u/814785?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ben Hagen</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Acbenhagen" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=cbenhagen" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/minhvn"><img src="https://avatars.githubusercontent.com/u/187747?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Võ Ngọc Minh</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Aminhvn" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://cesarsanz.dev/"><img src="https://avatars.githubusercontent.com/u/9842735?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cesar Sanz</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Acsanz91" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+author%3Acsanz91" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/TheKvikk"><img src="https://avatars.githubusercontent.com/u/4430316?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kvikk</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+author%3ATheKvikk" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Bmooij"><img src="https://avatars.githubusercontent.com/u/9463244?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Bob</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ABmooij" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+author%3ABmooij" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/R1cs1KING"><img src="https://avatars.githubusercontent.com/u/22369588?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Richard Tarnoczi</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AR1cs1KING" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/mrm"><img src="https://avatars.githubusercontent.com/u/141798?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Matthijs Meulenbrug</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Amrm" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://www.crifan.com/"><img src="https://avatars.githubusercontent.com/u/2750682?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Crifan Li</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Acrifan" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+author%3Acrifan" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/julienrbrt"><img src="https://avatars.githubusercontent.com/u/29894366?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Julien Robert</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=julienrbrt" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/example?author=julienrbrt" title="Examples">💡</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=julienrbrt" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/Njuelle"><img src="https://avatars.githubusercontent.com/u/3192870?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nicolas Juelle</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ANjuelle" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=Njuelle" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=Njuelle" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/Niek"><img src="https://avatars.githubusercontent.com/u/213140?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Niek van der Maas</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ANiek" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3ANiek" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=Niek" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Nico04"><img src="https://avatars.githubusercontent.com/u/34476051?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nicolas B</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ANico04" title="Bug reports">🐛</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://bhikadia.com/"><img src="https://avatars.githubusercontent.com/u/4963236?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Harsh Bhikadia</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=daadu" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3Adaadu" title="Reviewed Pull Requests">👀</a> <a href="#maintenance-daadu" title="Maintenance">🚧</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=daadu" title="Documentation">📖</a> <a href="#ideas-daadu" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/itsJoKr"><img src="https://avatars.githubusercontent.com/u/11093480?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Josip Krnjic</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AitsJoKr" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/ConProgramming"><img src="https://avatars.githubusercontent.com/u/20548516?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Conner Aldrich</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AConProgramming" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/RossinesP"><img src="https://avatars.githubusercontent.com/u/6748573?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pierre Rossinès</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+author%3ARossinesP" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/andzejsw"><img src="https://avatars.githubusercontent.com/u/7814734?v=4?s=100" width="100px;" alt=""/><br /><sub><b>andzejsw</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Aandzejsw" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/sanjay4one"><img src="https://avatars.githubusercontent.com/u/6861594?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sanjay Sah</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Asanjay4one" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://qiita.com/Dreamwalker"><img src="https://avatars.githubusercontent.com/u/19484515?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Dreamwalker</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AJAICHANGPARK" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/krishnaaro"><img src="https://avatars.githubusercontent.com/u/37663346?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kriss_Frost</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Akrishnaaro" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://asiantech.vn/"><img src="https://avatars.githubusercontent.com/u/14215709?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Binh Do D.</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Amvn-binhdo-dn" title="Bug reports">🐛</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/mvn-quannguyen2-dn"><img src="https://avatars.githubusercontent.com/u/40161877?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Quan Nguyen H. VN.Danang</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=mvn-quannguyen2-dn" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/guyluz11"><img src="https://avatars.githubusercontent.com/u/9304740?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Guy Luz</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Aguyluz11" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/yurir"><img src="https://avatars.githubusercontent.com/u/695168?v=4?s=100" width="100px;" alt=""/><br /><sub><b>yurir</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Ayurir" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/BillMac4440"><img src="https://avatars.githubusercontent.com/u/77397887?v=4?s=100" width="100px;" alt=""/><br /><sub><b>BillMac4440</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ABillMac4440" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3ABillMac4440" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://www.evolware.org/"><img src="https://avatars.githubusercontent.com/u/19709142?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Federico Pellegrin</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=fedepell" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3Afedepell" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Afedepell" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=fedepell" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/diegotori"><img src="https://avatars.githubusercontent.com/u/1844568?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Diego Tori</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3Adiegotori" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/IskanderA1"><img src="https://avatars.githubusercontent.com/u/54811073?v=4?s=100" width="100px;" alt=""/><br /><sub><b>IskanderA1</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/search?q=IskanderA1&type=commits" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/EgHubs"><img src="https://avatars.githubusercontent.com/u/73994357?v=4?s=100" width="100px;" alt=""/><br /><sub><b>EgHubs</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AEgHubs" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://mavyfaby.ml/"><img src="https://avatars.githubusercontent.com/u/51808724?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Maverick G. Fabroa</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=mavyfaby" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/example?author=mavyfaby" title="Examples">💡</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits/master/packages/wifi_iot/README.md?author=mavyfaby" title="Documentation">📖</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3Amavyfaby" title="Reviewed Pull Requests">👀</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/BenoitDuffez"><img src="https://avatars.githubusercontent.com/u/802209?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Benoit Duffez</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ABenoitDuffez" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://jscd.pw/"><img src="https://avatars.githubusercontent.com/u/30761811?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Justin DeSimpliciis</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=jscd" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/DominikStarke"><img src="https://avatars.githubusercontent.com/u/5812061?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Dominik Starke</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3ADominikStarke" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=DominikStarke" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/felixsmart"><img src="https://avatars.githubusercontent.com/u/48223844?v=4?s=100" width="100px;" alt=""/><br /><sub><b>FelixSmart</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Afelixsmart" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/briansemrau"><img src="https://avatars.githubusercontent.com/u/6376721?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Brian Semrau</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Abriansemrau" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/Hallot"><img src="https://avatars.githubusercontent.com/u/3803503?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hallot</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3AHallot" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=Hallot" title="Code">💻</a> <a href="https://github.com/flutternetwork/WiFiFlutter/pulls?q=is%3Apr+reviewed-by%3AHallot" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/pedrojalbuquerque"><img src="https://avatars.githubusercontent.com/u/65260772?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pedro Albuquerque</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Apedrojalbuquerque" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/starsoft4u"><img src="https://avatars.githubusercontent.com/u/64193300?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Starsoft4u</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Astarsoft4u" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/troyredder"><img src="https://avatars.githubusercontent.com/u/30933678?v=4?s=100" width="100px;" alt=""/><br /><sub><b>troyredder</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Atroyredder" title="Bug reports">🐛</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/nathan2day"><img src="https://avatars.githubusercontent.com/u/17063283?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nathan</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Anathan2day" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/nikolip"><img src="https://avatars.githubusercontent.com/u/44801617?v=4?s=100" width="100px;" alt=""/><br /><sub><b>nikolip</b></sub></a><br /><a href="https://github.com/flutternetwork/WiFiFlutter/issues?q=author%3Anikolip" title="Bug reports">🐛</a> <a href="https://github.com/flutternetwork/WiFiFlutter/commits?author=nikolip" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
