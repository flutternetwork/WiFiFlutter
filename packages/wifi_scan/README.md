<h3><a href="https://wifi.flutternetwork.dev/" ><img src="https://raw.githubusercontent.com/flutternetwork/WiFiFlutter/master/logo/logo%2Bname_vertical_color.png" alt="WiFiFlutter" height="112"/></a>| <code>wifi_scan</code></h3>

<p>  
<a href="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_scan.yaml">
  <img src="https://github.com/flutternetwork/WiFiFlutter/actions/workflows/wifi_scan.yaml/badge.svg" alt="analysis">
</a>  
<a href="https://pub.dev/packages/wifi_scan">
  <img src="https://img.shields.io/pub/v/wifi_scan?logo=dart" alt="pub.dev">
</a>
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://badges.bar/wifi_scan/pub%20points" alt="pub points">
</a>  
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://badges.bar/wifi_scan/popularity" alt="popularity">
</a>  
<a href="https://pub.dev/packages/wifi_scan/score">
  <img src="https://badges.bar/wifi_scan/likes" alt="likes">
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
  // start full scan async-ly
  final error = await WiFiScan.instance.startScan(askPermissions: true);
  if (error != null) {
    switch(error) {
      // handle error for values of StartScanErrors
    }
  }
}
```

For more details, you can read documentation of [`WiFiScan.startScan`][doc_startScan], 
[`StartScanErrors`][doc_StartScanErrors] and [`Result<ValueType, ErrorType>`][doc_Result].

### Get scanned results
You can get scanned results with `WiFiScan.getScannedResults` API, as shown below:
```dart
void _getScannedResults() async {
  // get scanned results
  final result = await WiFiScan.instance.getScannedResults(askPermissions: true);
  if (result.hasError){
    switch (error){
      // handle error for values of GetScannedResultErrors
    }
  } else {
    final accessPoints = result.value;
    // ...
  }
}
```

> **NOTE:** `getScannedResults` API can be used independently of `startScan` API. This returns the latest available scanned results.

For more details, you can read documentation of [`WiFiScan.getScannedResults`][doc_getScannedResults], 
[`WiFiAccessPoint`][doc_WiFiAccessPoint], [`GetScannedResultsErrors`][doc_GetScannedResultsErrors] and 
[`Result<ValueType, ErrorType>`][doc_Result].

### Get notified when scanned results available
You can get notified when new scanned results are available with `WiFiScan.onScannedResultsAvailable` API, as shown below:
```dart
// initialize accessPoints and subscription
List<WiFiAccessPoint> accessPoints = [];
StreamSubscription<Result<List<WiFiAccessPoint>, GetScannedResultErrors>>? subscription;

void _startListeningToScannedResults() async {
  // listen to onScannedResultsAvailable stream
  subscription = WiFiScan.instance.onScannedResultsAvailable.listen((result) {
    if (result.hasError){
      switch (error){
      // handle error for values of GetScannedResultErrors
      }  
    } else {
      // update accessPoints
      setState(() => accessPoints = result.value);
    }
  });
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
[`WiFiAccessPoint`][doc_WiFiAccessPoint], [`GetScannedResultsErrors`][doc_GetScannedResultsErrors] and 
[`Result<ValueType, ErrorType>`][doc_Result].

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
[doc_StartScanErrors]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/StartScanErrors.html
[doc_Result]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/Result-class.html
[doc_getScannedResults]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/getScannedResults.html
[doc_WiFiAccessPoint]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiAccessPoint-class.html
[doc_GetScannedResultsErrors]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/GetScannedResultsErrors.html
[doc_onScannedResultsAvailable]: https://pub.dev/documentation/wifi_scan/latest/wifi_scan/WiFiScan/onScannedResultsAvailable.html

[flutter_StreamBuilder]: https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html

[android_guide]: https://developer.android.com/guide/topics/connectivity/wifi-scan
[android_throttling]: https://developer.android.com/guide/topics/connectivity/wifi-scan#wifi-scan-throttling
[android_WifiManager]: https://developer.android.com/reference/android/net/wifi/WifiManager

[ios_thread]: https://developer.apple.com/forums/thread/39204
[ios_special]: https://developer.apple.com/forums/thread/91351?answerId=276151022#276151022
[ios_stub]: https://github.com/flutternetwork/WiFiFlutter/blob/master/packages/wifi_scan/ios/Classes/SwiftWifiScanPlugin.swift
