import 'package:async/async.dart';
import 'package:collection/collection.dart';
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

  Future<bool> isSupported() {
    return _isSupportedMemo.runOnce(() async {
      return (await _channel.invokeMethod<bool>('isSupported'))!;
    });
  }

  Future<WiFiGenerations> getGeneration() {
    return _getGenerationMemo.runOnce(() async {
      return (await _channel.invokeMethod<int?>("getGeneration"))
          .toWifiGeneration();
    });
  }

  Future<bool> isEnabled() async {
    return (await _channel.invokeMethod<bool>('isEnabled'))!;
  }

  Future<bool> setEnabled(bool enabled) async {
    return (await _channel.invokeMethod<bool>(
      'setEnabled',
      {"enabled": enabled},
    ))!;
  }

  Future<void> openSettings() async {
    await _channel.invokeMethod<void>("openSettings");
  }

  Future<WiFiInfo> getCurrentInfo() async {
    return WiFiInfo._fromMap(
      await _channel.invokeMapMethod<String, dynamic>("getCurrentInfo") ?? {},
    );
  }
}
