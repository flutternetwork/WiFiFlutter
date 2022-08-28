<h3><a href="https://wifi.flutternetwork.dev/" ><img src="https://raw.githubusercontent.com/flutternetwork/WiFiFlutter/master/logo/logo%2Bname_vertical_color.png" alt="WiFiFlutter" height="112"/></a>| <code>wifi_scan</code></h3>

<p>
<a href="https://flutternetwork.dev">
  <img src="https://raw.githubusercontent.com/flutternetwork/.github/master/profile/badge.svg" alt="Flutter Network" />
</a>
<a href="https://pub.dev/packages/wifi_scan">
  <img src="https://img.shields.io/pub/v/wifi_scan?logo=dart" alt="pub.dev">
</a>
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://img.shields.io/pub/points/wifi_scan?logo=dart" alt="pub points">
</a>  
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://img.shields.io/pub/popularity/wifi_scan?logo=dart" alt="popularity">
</a>  
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://img.shields.io/pub/likes/wifi_scan?logo=dart" alt="likes">
</a>  
</p>  

---
This plugin allows Flutter apps to scan for nearby visible WiFi access points.

> This plugin is part of [WiFiFlutter][wf_home] suite, enabling various WiFi services for Flutter. 

## Platform Support

| Platform | Status | Min. Version |  API  | Notes |
| :------: | :----: |:------------:| :---: |:-----:|
| **Android** | ✔️ | 16 (J) | Scan related APIs in [`WifiManager`][android_WifiManager] *[[Guide][android_guide]]* | For SDK >= 26(O) scans are [throttled][android_throttling]. |
| **iOS** | ✔️ | 9.0 | [No public API][ios_thread], requires [special entitlements from Apple][ios_special] | [Stub implementation][ios_stub] with sane returns. |

## Usage
The entry point for the plugin is the singleton instance `WiFiScan.instance`.

### Start scan
You can trigger full WiFi scan with `WiFiScan.startScan` API, as shown below:
```dart
void _startScan() async {
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canStartScan(askPermissions: true);
  switch(can) {
    case CanStartScan.yes:
      // start full scan async-ly
      final isScanning = await WiFiScan.instance.startScan();
      //...
      break;
    // ... handle other cases of CanStartScan values
  }
}
```

For more details, you can read documentation of [`WiFiScan.startScan`][doc_startScan], 
[`WiFiScan.canStartScan`][doc_canStartScan] and [`CanStartScan`][doc_enum_CanStartScan].

### Get scanned results
You can get scanned results with `WiFiScan.getScannedResults` API, as shown below:
```dart
void _getScannedResults() async {
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
  switch(can) {
    case CanGetScannedResults.yes:
      // get scanned results
      final accessPoints = await WiFiScan.instance.getScannedResults();
      // ...
      break;
    // ... handle other cases of CanGetScannedResults values
  }
}
```

> **NOTE:** `getScannedResults` API can be used independently of `startScan` API. This returns the latest available scanned results.

For more details, you can read documentation of [`WiFiScan.getScannedResults`][doc_getScannedResults],
[`WiFiAccessPoint`][doc_WiFiAccessPoint],
[`WiFiScan.canGetScannedResults`][doc_canGetScannedResults] and
[`CanGetScannedResults`][doc_enum_CanGetScannedResults].

### Get notified when scanned results available
You can get notified when new scanned results are available with `WiFiScan.onScannedResultsAvailable` API, as shown below:
```dart
// initialize accessPoints and subscription
List<WiFiAccessPoint> accessPoints = [];
StreamSubscription<List<WiFiAccessPoint>>? subscription;

void _startListeningToScannedResults() async {
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
  switch(can) {
    case CanGetScannedResults.yes:
      // listen to onScannedResultsAvailable stream
      subscription = WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        // update accessPoints
        setState(() => accessPoints = results);
      });
      // ...
      break;
    // ... handle other cases of CanGetScannedResults values
  }
}

// make sure to cancel subscription after you are done
@override
dispose() {
  super.dispose();
  subscription?.cancel();
}
```

Additionally, `WiFiScan.onScannedResultsAvailable` API can also be used with Flutter's 
[`StreamBuilder`][flutter_StreamBuilder] widget.

> **NOTE:** `onScannedResultsAvailable` API can be used  independently of `startScan` API. The notification can also be result of a full scan performed by platform or other app.

For more details, you can read documentation of 
[`WiFiScan.onScannedResultsAvailable`][doc_onScannedResultsAvailable],
[`WiFiAccessPoint`][doc_WiFiAccessPoint],
[`WiFiScan.canGetScannedResults`][doc_canGetScannedResults] and
[`CanGetScannedResults`][doc_enum_CanGetScannedResults].

## Resources
- 📖[API docs][docs]
- 💡[Example app][example]

## Issues and feedback

Please file WiFiFlutter specific issues, bugs, or feature requests in our [issue tracker][wf_issue].

To contribute a change to this plugin, please review plugin [checklist for 1.0][checklist], our 
[contribution guide][wf_contrib] and open a [pull request][wf_pull].

## Contributors ✨

Thanks goes to [these 💖 people][wf_contributors] for their contributions.

This project follows the [all-contributors][all_contributors] specification. Contributions of any kind welcome!

<!-- links -->
[wf_home]: https://wifi.flutternetwork.dev/
[wf_issue]: https://github.com/flutternetwork/WiFiFlutter/issues/new
[wf_contrib]: https://github.com/flutternetwork/WiFiFlutter/blob/master/CONTRIBUTING.md
[wf_pull]: https://github.com/flutternetwork/WiFiFlutter/pulls
[wf_contributors]: https://github.com/flutternetwork/WiFiFlutter/blob/master/CONTRIBUTORS.md
[all_contributors]: https://github.com/all-contributors/all-contributors

[checklist]: https://github.com/flutternetwork/WiFiFlutter/issues/188
[docs]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/wifi_scan-library.html
[example]: https://github.com/flutternetwork/WiFiFlutter/tree/master/packages/wifi_scan/example

[doc_startScan]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/startScan.html
[doc_canStartScan]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/canStartScan.html
[doc_enum_CanStartScan]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/CanStartScan.html
[doc_getScannedResults]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/getScannedResults.html
[doc_WiFiAccessPoint]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiAccessPoint-class.html
[doc_canGetScannedResults]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/canGetScannedResults.html
[doc_enum_CanGetScannedResults]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/CanGetScannedResults.html
[doc_onScannedResultsAvailable]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/onScannedResultsAvailable.html

[flutter_StreamBuilder]: https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html

[android_guide]: https://developer.android.com/guide/topics/connectivity/wifi-scan
[android_throttling]: https://developer.android.com/guide/topics/connectivity/wifi-scan#wifi-scan-throttling
[android_WifiManager]: https://developer.android.com/reference/android/net/wifi/WifiManager

[ios_thread]: https://developer.apple.com/forums/thread/39204
[ios_special]: https://developer.apple.com/forums/thread/91351?answerId=276151022#276151022
[ios_stub]: https://github.com/flutternetwork/WiFiFlutter/blob/master/packages/wifi_scan/ios/Classes/SwiftWifiScanPlugin.swift
