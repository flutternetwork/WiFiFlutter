import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scan/wifi_scan.dart';

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

  test('canStartScan', () async {
    mockHandlers["canStartScan"] = (_) => 1;
    expect(await WiFiScan.instance.canStartScan(), CanStartScan.yes);
  });

  test('startScan', () async {
    mockHandlers["startScan"] = (_) => true;
    expect(await WiFiScan.instance.startScan(), true);
  });

  test("canGetScannedNetworks", () async {
    mockHandlers["canGetScannedNetworks"] = (_) => 1;
    expect(await WiFiScan.instance.canGetScannedNetworks(),
        CanGetScannedNetworks.yes);
  });

  test("scannedNetworks", () async {
    mockHandlers["scannedNetworks"] = (_) => [{}];
    final scannedNetworks = await WiFiScan.instance.scannedNetworks;
    expect(scannedNetworks.length, 1);
  });

  // TODO: firgure out way to mock EventChannel
  // test("scannedNetworksStream", () async {});

  test("deserializeCanStartScan", () async {
    // +ve test
    final codes = [0, 1, 2, 3, 4];
    final enumValues = codes.map(deserializeCanStartScan).toList();
    expect(enumValues, [
      CanStartScan.notSupported,
      CanStartScan.yes,
      CanStartScan.noLocationPermissionRequired,
      CanStartScan.noLocationPermissionDenied,
      CanStartScan.noLocationServiceDisabled,
    ]);

    // -ve test
    expect(()=>deserializeCanGetScannedNetworks(-1), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(null), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(5), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(6), throwsUnsupportedError);
  });

  test("deserializeCanGetScannedNetworks", () async {
    // +ve test
    final codes = [0, 1, 2, 3, 4];
    final enumValues = codes.map(deserializeCanGetScannedNetworks).toList();
    expect(enumValues, [
      CanGetScannedNetworks.notSupported,
      CanGetScannedNetworks.yes,
      CanGetScannedNetworks.noLocationPermissionRequired,
      CanGetScannedNetworks.noLocationPermissionDenied,
      CanGetScannedNetworks.noLocationServiceDisabled,
    ]);

    // -ve test
    expect(()=>deserializeCanGetScannedNetworks(-1), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(null), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(5), throwsUnsupportedError);
    expect(()=>deserializeCanGetScannedNetworks(6), throwsUnsupportedError);
  });
}
