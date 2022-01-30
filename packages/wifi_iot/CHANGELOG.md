## 0.3.15

 - **FIX**: iOS accept connect function password argument to be nil (#224).
 - **FIX**: `findAndConnect` - param inter-changed (#245).
 - **FIX**: `disconnect` - returning result properly  (#242).
 - **FEAT**: remove `WifiNetworkSuggestion` for >=R (#243).

## 0.3.14

 - **FIX**: add size restrictions on the SSID according to IEEE Std 802.11 (#222).

## 0.3.13

 - **FIX**: `forceWifiUsage` for iOS not returning any result (#213).
 - **FEAT**: add a boolean return value to disconnect (#218).
 - **FEAT**: allow to specify the bssid for registering and connecting network (#217).

## 0.3.12 2021-12-17

 - **FIX**: `serializeNetworkSecurityMap` not mapping to null (#212).
 - **CHORE**: added lint rules for docs (#209).

## 0.3.11 2021-12-08

 - **FIX**: proper serializing to avoid issue when obfuscated (#207).
 - **DOCS**: smaller banner.

## 0.3.10 2021-11-28

 - **DOCS**: proper banner with package name.

## 0.3.9 2021-11-28

 - **STYLE**: as per anaylzer (#204).
 - **REFACTOR**: prepare for multiple plugins (#195).
 - **FIX**: `forceWifiUsage` not calling "not implemented" error (#203).
 - **FIX**: ci checks (#196).
 - **DOCS**: proper badges and logo (#199).
 - **CHORE**: not publishing example app (#200).

## 0.3.8 2021-09-22

* feat(ios): getIP implemented (#176)

## 0.3.7 2021-09-19

* fix(ios): getSSID and getBSSID always returning null (#175)

## 0.3.6 2021-09-07

* fix(android): keyword typo (#173)

## 0.3.5 2021-09-06

* feat(android): Gracefully handle permission requests (#169)

## 0.3.4 2021-07-09

* refactor(ios): handle deprecation of `CNCopyCurrentNetworkInfo` (#150)

## 0.3.3 2021-05-12

* removed mac filtering (unimplemented methods) [#141]
* feat(android) hidden SSID support added [#145]
* call startScan on Android P [#146]

## 0.3.2 2021-05-07

* readme - mentioned #140 and other minor

## 0.3.1 2021-04-22

* revamp - example app, wifi ap functions (android only) [#126]

## 0.3.0 2021-03-15

* dart null saftey [#124]

## 0.2.2 2021-02-18

* minor fix in `connect` and `findAndConnect` on Android [#118]
* added `withInternet` argument to `connect` and `findAndConnect` on Android [#99]

## 0.2.1 2021-02-14

* added `showWritePermissionSettings` on Android [#112]
* added `registerWifiNetwork` on Android [#113]
* implemented `forceWifiUsage` on iOS to trigger LocalNetwork permission [#115]

## 0.2.0 2020-11-26

* Fix the force_wifi method on Android
* Remove some verbose logs (Fixes #69)
* Replaced deprecated methods for wifi features in Android SDK 29

## 0.1.0 2020-01-03

* Refractor example app
* Remove unecessary permissions for `forceWifiUsage`
