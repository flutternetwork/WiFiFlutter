import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scan/wifi_scan.dart';

Map _makeResult({dynamic value, dynamic error}) {
  assert((value != null) ^ (error != null));
  if (error != null) return {"error": error};
  return {"value": value};
}

void main() {
  const channel = MethodChannel('wifi_scan');
  final mockHandlers = <String, Function(dynamic arguments)>{};

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
      final result = mockHandlers[call.method]?.call(call.arguments);
      if (result is Future) return result;
      return Future.value(result);
    });
  });

  tearDown(() {
    mockHandlers.clear();
    channel.setMockMethodCallHandler(null);
  });

  group("startScan", () {
    test('successful', () async {
      mockHandlers["startScan"] = (_) => null;
      expect(await WiFiScan.instance.startScan(), isNull);
    });

    test("fail with valid code", () async {
      final errorCodes = [0, 1, 2, 3, 4, 5];
      final enumValues = [
        StartScanErrors.notSupported,
        StartScanErrors.noLocationPermissionRequired,
        StartScanErrors.noLocationPermissionDenied,
        StartScanErrors.noLocationPermissionUpgradeAccuracy,
        StartScanErrors.noLocationServiceDisabled,
        StartScanErrors.failed,
      ];
      for (int i = 0; i < errorCodes.length; i++) {
        mockHandlers["startScan"] = (_) => errorCodes[i];
        expect(await WiFiScan.instance.startScan(), enumValues[i]);
      }
    });

    test("fail with in valid code", () {
      final badErrorCodes = [-1, 6, 7];
      for (var erroCode in badErrorCodes) {
        mockHandlers["startScan"] = (_) => erroCode;
        expect(() async => await WiFiScan.instance.startScan(),
            throwsUnsupportedError);
      }
    });
  });

  group("getScannedResults", () {
    test("successfull", () async {
      mockHandlers["getScannedResults"] = (_) => _makeResult(value: [
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
          ]);
      final result = await WiFiScan.instance.getScannedResults();
      expect(result.hasError, false);
      expect(result.value, isNotNull);
      expect(result.value!.length, 1);
    });

    test("fail with valid code", () async {
      final errorCodes = [0, 1, 2, 3, 4];
      final enumValues = [
        GetScannedResultsErrors.notSupported,
        GetScannedResultsErrors.noLocationPermissionRequired,
        GetScannedResultsErrors.noLocationPermissionDenied,
        GetScannedResultsErrors.noLocationPermissionUpgradeAccuracy,
        GetScannedResultsErrors.noLocationServiceDisabled,
      ];
      for (int i = 0; i < errorCodes.length; i++) {
        mockHandlers["getScannedResults"] =
            (_) => _makeResult(error: errorCodes[i]);
        final result = await WiFiScan.instance.getScannedResults();
        expect(result.hasError, true);
        expect(result.error, isNotNull);
        expect(result.error, enumValues[i]);
      }
    });

    test("fail with invalid code", () async {
      final badCanCodes = [-1, 6, 7];
      for (int i = 0; i < badCanCodes.length; i++) {
        mockHandlers["getScannedResults"] =
            (_) => _makeResult(error: badCanCodes[i]);
        expect(() async => await WiFiScan.instance.getScannedResults(),
            throwsUnsupportedError);
      }
    });
  });

  // TODO: firgure out way to mock EventChannel
  // test("onScannedResultsAvailable", () async {});
}
