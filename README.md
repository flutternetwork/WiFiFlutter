<img src="https://raw.githubusercontent.com/alternadom/WiFiFlutter/master/logo/logo%2Bname_color.png" alt="WiFiFlutter" width="255" height="160" />

[![pub](https://img.shields.io/pub/v/wifi_iot.svg?style=flat-square)](https://pub.dartlang.org/packages/wifi_iot)

## Introduction

Plugin Flutter which can handle WiFi connections (AP, STA)

Becareful, some commands as no effect on iOS because Apple don't let us to do whatever we want...

## Android Permissions
The plugin requires the following permissions to work properly.
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
<uses-feature android:name="android.hardware.wifi" />
```

## WiFi connections
|                      Description                      |      Android       |         iOS          |
| :---------------------------------------------------- | :----------------: | :------------------: |
| Enabling / Disabling WiFi module                      | :warning:(5a) |  :x:  |
| Getting WiFi status                                   | :white_check_mark: |  :x:  |
| Scanning for networks, with "already-associated" flag | :white_check_mark: |  :x:  |
| Connecting / Disconnecting on a network in WPA / WEP  | :white_check_mark:(5b) |  :white_check_mark:(1)  |
| Registering / Unregistering a WiFi network            | :white_check_mark:(5c) |  :warning:(2)  |
| Getting informations like :                           | :white_check_mark: |  :warning:(3)  |
| - SSID                                                | :white_check_mark: |  :white_check_mark:  |
| - BSSID                                               | :white_check_mark: |  :x:  |
| - Current signal strength                             | :white_check_mark: |  :x:  |
| - Frequency                                           | :white_check_mark: |  :x:  |
| - IP                                                  | :white_check_mark: |  :question:(4)  |

:white_check_mark:(1) : On iOS, you can only disconnect from a network which has been added by your app. In order to disconnect from a system network, you have to connect to an other!

:warning:(2) : On iOS, you can forget a WiFi network by connecting to it with the joinOnce flag to true!

:warning:(3) : On iOS, you can just getting the SSID, or maybe(probably) I'm missing something! 

:question:(4) : I think there is a way to get the IP address but for now, this is not implemented..

:warning:(5): Wifi API changes in Android SDK >= 29, restricts certain behaviour:
  * a. Enable/Disable Wifi Module is deprecated and will always fail [[docs](https://developer.android.com/reference/android/net/wifi/WifiManager#setWifiEnabled(boolean))]. If you  want to open "Wifi Setting" in that case then, set the `shouldOpenSettings: true` when calling `setEnabled`.
  * b. For Connecting to Wifi, WEP security is deprecated and will always fail, also the network will be disconnected when the app is closed (if permanent network is required(Check :warning:(5c)), use "Register Network" feature) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-bootstrap))]. By default the connection would not have internet access, to connect to network with internet user `withInternet` which is a different API underneath (this API will not disconnect to network after app closes) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-suggest)].
  * c. Registering Wifi Network, will require user approval - and the network saved would not be controlled by the app (for deletion, updation, etc) [[docs](https://developer.android.com/guide/topics/connectivity/wifi-save-network-passpoint-config)];

## Access Point
|                                       Description                                     |      Android       |         iOS          |
| :------------------------------------------------------------------------------------ | :----------------: | :------------------: |
| Getting the status of the Access Point (Disable, disabling, enable, enabling, failed) | :warning:(1a) |  :x:  |
| Enabling / Disabling Access Point                                                     | :white_check_mark:(1b) |  :x:  |
| Getting / Setting new credentials (SSID / Password)                                   | :warning:(1a) |  :x:  |
| Enabling / Disabling the visibility of the SSID Access Point                          | :warning:(1a) |  :x:  |
| Getting the clients list (IP, BSSID, Device, Reachable)                               | :white_check_mark: |  :x:  |
| Handling the MAC filtering                                                            | :sos: |  :x:  |

:warning:(1): Wifi API changes in Android SDK >= 29, restricts certain behaviour:
  * a. This has been deprecated and will always fail for >= 29 Android SDK.
  * b. Uses [`startLocalOnlyHotspot` API](https://developer.android.com/reference/android/net/wifi/WifiManager#startLocalOnlyHotspot(android.net.wifi.WifiManager.LocalOnlyHotspotCallback,%20android.os.Handler)) to enable or disable WiFi AP. This can only be used to communicate between co-located devices connected to the created WiFi Hotspot. Note - (i) Enabling and Disabling WiFi AP needs to request location permission; (ii) The network created by this method will not have Internet access; (iii) There's no other way to set WiFi AP's SSID and Passphrase.

For now, there is no way to set the access point on iOS... 

## Xcode build (iOS >= 8.0)

To be able to build with Xcode, you must specify `use_frameworks!` in your Podfile to allow building Swift into static libraries.

## Troubleshooting

Don't hesitate and come [here](https://github.com/alternadom/WiFiFlutter/issues), we will be happy to help you!
