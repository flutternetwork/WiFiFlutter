import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_connect_to/wifi_connect_to.dart';
import 'package:wifi_connect_to/wifi_connect_to_platform_interface.dart';
import 'package:wifi_connect_to/wifi_connect_to_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWifiConnectToPlatform
    with MockPlatformInterfaceMixin
    implements WifiConnectToPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WifiConnectToPlatform initialPlatform = WifiConnectToPlatform.instance;

  test('$MethodChannelWifiConnectTo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiConnectTo>());
  });

  test('getPlatformVersion', () async {
    WifiConnectTo wifiConnectToPlugin = WifiConnectTo();
    MockWifiConnectToPlatform fakePlatform = MockWifiConnectToPlatform();
    WifiConnectToPlatform.instance = fakePlatform;

    expect(await wifiConnectToPlugin.getPlatformVersion(), '42');
  });
}
