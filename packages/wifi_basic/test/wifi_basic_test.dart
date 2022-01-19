import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_basic/src/extensions.dart';
import 'package:wifi_basic/wifi_basic.dart';

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
    final value = {
      "ssid": "my-wifi",
      "bssid": "02:00:00:00:00:00",
      "security": 0,
      "isHidden": false,
      "rssi": -100,
      "signalStrength": 1.0,
      "hasInternet": true,
      "generation": -1,
    };
    mockHandlers["getCurrentInfo"] = (_) => value;
    final info = await WiFiBasic.instance.getCurrentInfo();

    expect(info, WiFiInfo.fromMap(value));
  });

  test("test WiFiGenerationsExtension", () {
    final intValues = [-1, 0, 1, 2, 3, 4, 5, 6, 7, null];

    final enumValues = intValues.map(WiFiGenerationsExtension.fromInt).toList();

    expect(enumValues, [
      WiFiGenerations.unknown,
      WiFiGenerations.legacy,
      WiFiGenerations.legacy,
      WiFiGenerations.legacy,
      WiFiGenerations.legacy,
      WiFiGenerations.wifi4,
      WiFiGenerations.wifi5,
      WiFiGenerations.wifi6,
      WiFiGenerations.unknown,
      WiFiGenerations.unknown,
    ]);
  });

  test("test WiFiNetworkSecurityExtension", () {
    final intValues = [-1, 0, 1, 2, 3, 4, 5, 6, null];

    final enumValues =
        intValues.map(WiFiNetworkSecurityExtension.fromInt).toList();

    expect(enumValues, [
      WiFiNetworkSecurity.unknown,
      WiFiNetworkSecurity.unknown,
      WiFiNetworkSecurity.none,
      WiFiNetworkSecurity.wep,
      WiFiNetworkSecurity.wpa,
      WiFiNetworkSecurity.wpa2,
      WiFiNetworkSecurity.wpa3,
      WiFiNetworkSecurity.unknown,
      WiFiNetworkSecurity.unknown,
    ]);
  });
}
