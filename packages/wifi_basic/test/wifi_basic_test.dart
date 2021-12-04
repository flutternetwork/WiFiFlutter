import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_basic/wifi_basic.dart';

void main() {
  const MethodChannel channel = MethodChannel('wifi_basic');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    bool isEnabled = true;
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "isSupported":
          return true;
        case "getGeneration":
          return 3;
        case "isEnabled":
          return isEnabled;
        case "setEnabled":
          isEnabled = methodCall.arguments["enabled"];
          return true;
        case "openSettings":
          return null;
        default:
          throw MissingPluginException();
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('basic test', () async {
    expect(await WiFiBasic.instance.isSupported(), true);
    expect(await WiFiBasic.instance.getGeneration(), WiFiGenerations.legacy);
    expect(await WiFiBasic.instance.isEnabled(), true);
    expect(await WiFiBasic.instance.setEnabled(false), true);
    expect(await WiFiBasic.instance.isEnabled(), false);
    await WiFiBasic.instance.openSettings();
  });
}
