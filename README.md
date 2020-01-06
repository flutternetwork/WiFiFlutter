<img src="https://raw.githubusercontent.com/alternadom/WiFiFlutter/master/logo/logo%2Bname_color.png" alt="WiFiFlutter" width="255" height="160" />

[![pub](https://img.shields.io/pub/v/wifi_iot.svg?style=flat-square)](https://pub.dartlang.org/packages/wifi_iot)

## Introduction

Plugin Flutter which can handle WiFi connections (AP, STA)

Becareful, some commands as no effect on iOS because Apple don't let us to do whatever we want...

## WiFi connections
|                      Description                      |      Android       |         iOS          |
| :---------------------------------------------------- | :----------------: | :------------------: |
| Enabling / Disabling WiFi module                      | :white_check_mark: |  :x:  |
| Getting WiFi status                                   | :white_check_mark: |  :x:  |
| Scanning for networks, with "already-associated" flag | :white_check_mark: |  :x:  |
| Connecting / Disconnecting on a network in WPA / WEP  | :white_check_mark: |  :white_check_mark:(1)  |
| Registering / Unregistering a WiFi network            | :white_check_mark: |  :warning:(2)  |
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

## Access Point
|                                       Description                                     |      Android       |         iOS          |
| :------------------------------------------------------------------------------------ | :----------------: | :------------------: |
| Getting the status of the Access Point (Disable, disabling, enable, enabling, failed) | :white_check_mark: |  :x:  |
| Enabling / Disabling Access Point                                                     | :white_check_mark: |  :x:  |
| Getting / Setting new credentials (SSID / Password)                                   | :white_check_mark: |  :x:  |
| Enabling / Disabling the visibility of the SSID Access Point                          | :white_check_mark: |  :x:  |
| Getting the clients list (IP, BSSID, Device, Reachable)                               | :white_check_mark: |  :x:  |
| Handling the MAC filtering                                                            | :sos: |  :x:  |

For now, there is no way to set the access point on iOS... 

## Xcode build (iOS >= 8.0)

To be able to build with Xcode, you must specify `use_frameworks!` in your Podfile to allow building Swift into static libraries.

## Troubleshooting

Don't hesitate and come [here](https://github.com/alternadom/WiFiFlutter/issues), we will be happy to help you!
