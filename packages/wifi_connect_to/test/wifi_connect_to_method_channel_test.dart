import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_connect_to/wifi_connect_to_method_channel.dart';

void main() {
  MethodChannelWifiConnectTo platform = MethodChannelWifiConnectTo();
  const MethodChannel channel = MethodChannel('wifi_connect_to');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
