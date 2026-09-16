import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_basic/wifi_basic.dart';

import 'package:wifi_basic/src/extensions.dart' show ToEnumExtension;

void main() {
  const channel = MethodChannel('wifi_basic');
  final mockHandlers = <String, Function(dynamic arguments)>{};

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) =>
                Future.value(mockHandlers[call.method]?.call(call.arguments)));
  });

  tearDown(() {
    mockHandlers.clear();
    channel.setMockMethodCallHandler(null);
  });

  test("test isSupported", () async {
    mockHandlers["isSupported"] = (_) => true;
    final isSupported = await WiFiBasic.instance.isSupported();
    expect(isSupported, true);
    // test memoization - by changing the handler but getting the same result
    mockHandlers["isSupported"] = (_) => false;
    final isSupportedAgain = await WiFiBasic.instance.isSupported();
    expect(isSupportedAgain, isSupported);
  });

  test("test getGeneration", () async {
    mockHandlers["getGeneration"] = (_) => 3;
    final generation = await WiFiBasic.instance.getGeneration();
    expect(generation, WiFiGenerations.legacy);
    // test memoization - by changing the handler but getting the same result
    mockHandlers["getGeneration"] = (_) => -1;
    final generationAgain = await WiFiBasic.instance.getGeneration();
    expect(generationAgain, generation);
  });

  test("test getGeneration memoized", () async {
    // setup mock handler to return random getGeneration integer [-1, 6)
    mockHandlers["getGeneration"] = (_) => Random().nextInt(7) - 1;
    // call getGeneration
    final generation = await WiFiBasic.instance.getGeneration();
    // setup mock handler to return result not same as previous
    mockHandlers["getGeneration"] = (_) {
      WiFiGenerations _generation = generation;
      while (_generation != generation) {
        _generation = WiFiGenerations
            .values[Random().nextInt(WiFiGenerations.values.length)];
      }
    };
    // call getGeneration again
    final generationAgain = await WiFiBasic.instance.getGeneration();
    // both should be same - since result memoized
    expect(generationAgain, generation);
  });

  test("test isEnabled", () async {
    mockHandlers["isEnabled"] = (_) => true;
    expect(await WiFiBasic.instance.isEnabled(), true);
  });

  test("test setEnabled", () async {
    bool isEnabled = false;
    mockHandlers["isEnabled"] = (_) => isEnabled;
    mockHandlers["setEnabled"] = (arg) {
      isEnabled = arg["enabled"];
      return true;
    };
    expect(await WiFiBasic.instance.setEnabled(!isEnabled), true);
    expect(await WiFiBasic.instance.isEnabled(), isEnabled);
  });

  test("test openSettings", () async {
    mockHandlers["openSettings"] = (_) => null;
    await WiFiBasic.instance.openSettings();
  });

  test("test getCurrentInfo", () async {
    mockHandlers["getCurrentInfo"] = (_) => {
          "ssid": "my-wifi",
          "bssid": "02:00:00:00:00:00",
          "security": 0,
          "isHidden": false,
          "rssi": -100,
          "signalStrength": 1.0,
          "hasInternet": true,
          "generation": -1,
        };
    final info = await WiFiBasic.instance.getCurrentInfo();
    expect(info.ssid, "my-wifi");
    expect(info.bssid, "02:00:00:00:00:00");
    expect(info.security, WiFiNetworkSecurity.none);
    expect(info.isHidden, false);
    expect(info.rssi, -100);
    expect(info.signalStrength, 1.0);
    expect(info.hasInternet, true);
    expect(info.generation, WiFiGenerations.unknown);
  });

  test("test ToEnumExtension.toWifiGeneration", () async {
    // test for unknown
    expect((-1).toWifiGeneration(), WiFiGenerations.unknown);
    // test for legacy
    expect(Random().nextInt(3).toWifiGeneration(), WiFiGenerations.legacy);
    // test for wifi4, wifi5 and wifi6
    expect(4.toWifiGeneration(), WiFiGenerations.wifi4);
    expect(5.toWifiGeneration(), WiFiGenerations.wifi5);
    expect(6.toWifiGeneration(), WiFiGenerations.wifi6);
    // test for unknown again
    expect(
        (7 + Random().nextInt(10)).toWifiGeneration(), WiFiGenerations.unknown);
  });

  test("test ToEnumExtension.toWifiNetworkSecurity", () {
    // test for unknown
    expect((-1).toWifiNetworkSecurity(), WiFiNetworkSecurity.unknown);
    // test for values
    expect(0.toWifiNetworkSecurity(), WiFiNetworkSecurity.none);
    expect(1.toWifiNetworkSecurity(), WiFiNetworkSecurity.wep);
    expect(2.toWifiNetworkSecurity(), WiFiNetworkSecurity.wpa);
    expect(3.toWifiNetworkSecurity(), WiFiNetworkSecurity.wpa2);
    expect(4.toWifiNetworkSecurity(), WiFiNetworkSecurity.wpa3);
    // test for unknown again
    expect((7 + Random().nextInt(10)).toWifiNetworkSecurity(),
        WiFiNetworkSecurity.unknown);
  });
}
