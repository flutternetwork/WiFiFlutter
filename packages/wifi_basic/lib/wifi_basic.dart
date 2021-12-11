import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:wifi_basic/src/extensions.dart';

part 'wifi_generations.dart';
part 'wifi_info.dart';
part 'wifi_network_security.dart';

class WiFiBasic {
  WiFiBasic._();

  static final instance = WiFiBasic._();
  final MethodChannel _channel = const MethodChannel('wifi_basic');
  final _isSupportedMemo = AsyncMemoizer<bool>();
  final _getGenerationMemo = AsyncMemoizer<WiFiGenerations>();

  Future<bool> isSupported() => _isSupportedMemo
      .runOnce(() async => await _channel.invokeMethod('isSupported'));

  Future<WiFiGenerations> getGeneration() => _getGenerationMemo.runOnce(
      () async => (await _channel.invokeMethod("getGeneration") as int?)
          .toWifiGeneration());

  Future<bool> isEnabled() async => await _channel.invokeMethod('isEnabled');

  Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod('setEnabled', {"enabled": enabled});

  Future<void> openSettings() async =>
      await _channel.invokeMethod("openSettings");

  Future<WiFiInfo> getCurrentInfo() async =>
      WiFiInfo._fromMap(await _channel.invokeMapMethod("getCurrentInfo") ?? {});
}
