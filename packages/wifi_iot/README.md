<h3><a href="https://wifi.flutternetwork.dev/" ><img src="https://raw.githubusercontent.com/flutternetwork/WiFiFlutter/master/logo/logo%2Bname_vertical_color.png" alt="WiFiFlutter" height="112"/></a>| <code>wifi_iot</code></h3>

<p>
<a href="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml"><img src="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_iot.yaml/badge.svg" alt="analysis"></a>
<a href="https://pub.dev/packages/wifi_iot"><img src="https://img.shields.io/pub/v/wifi_iot?logo=dart" alt="pub.dev"></a>
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
| Scanning for networks, with "already-associated" flag | :white_check_mark:(4) |  :x:  |
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

:warning:(4): This functionality is "discontinued" - checkout new [`wifi_scan`](https://pub.dev/packages/wifi_scan) plugin (also by WiFiFlutter) instead.

Additional Wifi protocols on Android side like - Wifi Direct, Wifi Aware, etc are in active discussion at [#140](https://github.com/flutternetwork/WiFiFlutter/issues/140). Encourage you to engage if you want this features.

## Access Point
|                                       Description                                     |         Android        |         iOS          |
| :------------------------------------------------------------------------------------ | :--------------------: | :------------------: |
| Getting the status of the Access Point (Disable, disabling, enable, enabling, failed) | :warning:(1a)          |         :x:          |
| Enabling / Disabling Access Point                                                     | :white_check_mark:(1b) |         :x:          |
| Getting / Setting new credentials (SSID / Password)                                   | :warning:(1b - iii)    |         :x:          |
| Enabling / Disabling the visibility of the SSID Access Point                          | :warning:(1a)          |         :x:          |
| Getting the clients list (IP, BSSID, Device, Reachable)                               | :warning:(1a)          |         :x:          |

:warning:(1): Wifi API changes in Android SDK 26 and 29, restricts certain behaviour:
  * a. This has been deprecated and will always fail for >= 26 Android SDK.
  * b. Uses [`startLocalOnlyHotspot` API](https://developer.android.com/reference/android/net/wifi/WifiManager#startLocalOnlyHotspot(android.net.wifi.WifiManager.LocalOnlyHotspotCallback,%20android.os.Handler)) to request enabling or disabling WiFi AP for >= 26 Android SDK. This can only be used to communicate between co-located devices connected to the created WiFi Hotspot. Note - 
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

Thanks goes to [these 💖 people](https://github.com/flutternetwork/WiFiFlutter#contributors-) for their contributions.

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
