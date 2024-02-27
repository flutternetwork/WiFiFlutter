import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  const channel = MethodChannel('wifi_scan');
  final mockHandlers = <String, Function(dynamic arguments)>{};

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
      final result = mockHandlers[call.method]?.call(call.arguments);
      if (result is Future) return result;
      return Future.value(result);
    });
  });

  tearDown(() {
    mockHandlers.clear();
  });

  test('canStartScan', () async {
    final canCodes = [0, 1, 2, 3, 4, 5];
    final enumValues = [
      CanStartScan.notSupported,
      CanStartScan.yes,
      CanStartScan.noLocationPermissionRequired,
      CanStartScan.noLocationPermissionDenied,
      CanStartScan.noLocationPermissionUpgradeAccuracy,
      CanStartScan.noLocationServiceDisabled,
    ];
    for (int i = 0; i < canCodes.length; i++) {
      mockHandlers["canStartScan"] = (_) => canCodes[i];
      expect(await WiFiScan.instance.canStartScan(), enumValues[i]);
    }

    // -ve test
    final badCanCodes = [null, -1, 6, 7];
    for (int i = 0; i < badCanCodes.length; i++) {
      mockHandlers["canStartScan"] = (_) => badCanCodes[i];
      expect(() async => await WiFiScan.instance.canStartScan(),
          throwsUnsupportedError);
    }
  });

  test('startScan', () async {
    mockHandlers["startScan"] = (_) => true;
    expect(await WiFiScan.instance.startScan(), true);
  });

  test("canGetScannedResults", () async {
    final canCodes = [0, 1, 2, 3, 4, 5];
    final enumValues = [
      CanGetScannedResults.notSupported,
      CanGetScannedResults.yes,
      CanGetScannedResults.noLocationPermissionRequired,
      CanGetScannedResults.noLocationPermissionDenied,
      CanGetScannedResults.noLocationPermissionUpgradeAccuracy,
      CanGetScannedResults.noLocationServiceDisabled,
    ];
    for (int i = 0; i < canCodes.length; i++) {
      mockHandlers["canGetScannedResults"] = (_) => canCodes[i];
      expect(await WiFiScan.instance.canGetScannedResults(), enumValues[i]);
    }

    // -ve test
    final badCanCodes = [null, -1, 6, 7];
    for (int i = 0; i < badCanCodes.length; i++) {
      mockHandlers["canGetScannedResults"] = (_) => badCanCodes[i];
      expect(() async => await WiFiScan.instance.canGetScannedResults(),
          throwsUnsupportedError);
    }
  });

  test("getScannedResults", () async {
    mockHandlers["getScannedResults"] = (_) => [
          {
            "ssid": "my-ssid",
            "bssid": "00:00:00:12",
            "capabilities": "Unknown",
            "frequency": 600,
            "level": 5,
            "timestamp": null,
            "standard": null,
            "centerFrequency0": null,
            "centerFrequency1": null,
            "channelWidth": null,
            "isPasspoint": null,
            "operatorFriendlyName": null,
            "venueName": null,
            "is80211mcResponder": null,
          }
        ];
    final scannedNetworks = await WiFiScan.instance.getScannedResults();
    expect(scannedNetworks.length, 1);
  });

  // TODO: firgure out way to mock EventChannel
  // test("onScannedResultsAvailable", () async {});
}
