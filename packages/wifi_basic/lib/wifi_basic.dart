import 'package:async/async.dart';
import 'package:flutter/services.dart';

enum WiFiGenerations { unknown, legacy, wifi4, wifi5, wifi6 }

class WiFiBasic {
  WiFiBasic._();

  static final instance = WiFiBasic._();
  final MethodChannel _channel = const MethodChannel('wifi_basic');
  final _isSupportedMemo = AsyncMemoizer<bool>();
  final _getGenerationMemo = AsyncMemoizer<WiFiGenerations>();

  Future<bool> isSupported() => _isSupportedMemo
      .runOnce(() async => await _channel.invokeMethod('isSupported'));

  Future<WiFiGenerations> getGeneration() =>
      _getGenerationMemo.runOnce(() async {
        final int generation = await _channel.invokeMethod("getGeneration");
        // unknown - if generation out of enum index
        if (generation < 0 || generation > WiFiGenerations.values.length) {
          return WiFiGenerations.unknown;
        }
        // legacy - if less than 3
        if (generation <= 3) return WiFiGenerations.legacy;
        // convert generationInt -> generationEnum
        return WiFiGenerations.values[generation - 2];
      });

  Future<bool> isEnabled() async => await _channel.invokeMethod('isEnabled');

  Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod('setEnabled', {"enabled": enabled});

  Future<void> openSettings() async =>
      await _channel.invokeMethod("openSettings");
}
