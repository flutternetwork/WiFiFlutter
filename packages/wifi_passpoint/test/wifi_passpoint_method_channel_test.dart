import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_passpoint/wifi_passpoint_method_channel.dart';

void main() {
  MethodChannelWifiPasspoint platform = MethodChannelWifiPasspoint();
  const MethodChannel channel = MethodChannel('wifi_passpoint');

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
