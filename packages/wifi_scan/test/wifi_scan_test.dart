import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_scan/src/extensions.dart';
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
    mockHandlers["canStartScan"] = (_) => 0;
    expect(await WiFiScan.instance.canStartScan(), CanStartScan.yes);
  });

  test('startScan', () async {
    mockHandlers["startScan"] = (_) => true;
    expect(await WiFiScan.instance.startScan(), true);
  });

  test("canGetScannedNetworks", () async {
    mockHandlers["canGetScannedNetworks"] = (_) => 0;
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

  test("ToEnumExtension.toCanStartScan", () async {
    expect(0.toCanStartScan(), CanStartScan.yes);
    expect(1.toCanStartScan(), CanStartScan.notSupported);
    expect(2.toCanStartScan(), CanStartScan.noLocationPermissionRequired);
    expect(3.toCanStartScan(), CanStartScan.noLocationPermissionDenied);
    expect(4.toCanStartScan(), CanStartScan.noLocationServiceDisabled);
  });

  test("ToEnumExtension.toCanGetScannedNetworks", () async {
    expect(0.toCanGetScannedNetworks(), CanGetScannedNetworks.yes);
    expect(1.toCanGetScannedNetworks(), CanGetScannedNetworks.notSupported);
    expect(2.toCanGetScannedNetworks(),
        CanGetScannedNetworks.noLocationPermissionRequired);
    expect(3.toCanGetScannedNetworks(),
        CanGetScannedNetworks.noLocationPermissionDenied);
    expect(4.toCanGetScannedNetworks(),
        CanGetScannedNetworks.noLocationServiceDisabled);
  });
}
