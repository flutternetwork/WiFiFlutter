import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_basic/wifi_basic.dart';

void main() {
  const MethodChannel channel = MethodChannel('wifi_basic');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    bool isEnabled = true;
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch(methodCall.method) {
        case "hasCapability":
          return true;
        case "isEnabled":
          return isEnabled;
        case "setEnabled":
          isEnabled = methodCall.arguments["state"];
          break;
        default:
          throw MissingPluginException();
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('basic test', () async {
    expect(await WiFiBasic.hasCapability(), true);
    expect(await WiFiBasic.isEnabled(), true);
    await WiFiBasic.setEnabled(false);
    expect(await WiFiBasic.isEnabled(), false);
  });
}
