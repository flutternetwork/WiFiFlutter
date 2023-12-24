import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_passpoint/wifi_passpoint.dart';
import 'package:wifi_passpoint/wifi_passpoint_platform_interface.dart';
import 'package:wifi_passpoint/wifi_passpoint_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWifiPasspointPlatform
    with MockPlatformInterfaceMixin
    implements WifiPasspointPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WifiPasspointPlatform initialPlatform = WifiPasspointPlatform.instance;

  test('$MethodChannelWifiPasspoint is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiPasspoint>());
  });

  test('getPlatformVersion', () async {
    WifiPasspoint wifiPasspointPlugin = WifiPasspoint();
    MockWifiPasspointPlatform fakePlatform = MockWifiPasspointPlatform();
    WifiPasspointPlatform.instance = fakePlatform;

    expect(await wifiPasspointPlugin.getPlatformVersion(), '42');
  });
}
