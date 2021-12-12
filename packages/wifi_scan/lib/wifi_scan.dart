import 'dart:async';

import 'package:flutter/services.dart';

part 'can.dart';
part 'wifi_network.dart';

class WiFiScan {
  WiFiScan._();

  static final instance = WiFiScan._();
  final _channel = const MethodChannel('wifi_scan');
  final _scannedNetworksChannel =
      const EventChannel('wifi_scan/scannedNetworksEvent');
  Stream<List<WiFiNetwork>>? _scannedNetworksStream;

  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>(
      "canStartScan",
      {"askPermissions": askPermissions},
    );
    return _deserializeCanStartScan(canCode);
  }

  Future<bool> startScan() async {
    final isSucess = await _channel.invokeMethod<bool>("startScan");
    return isSucess!;
  }

  Future<CanGetScannedNetworks> canGetScannedNetworks(
      {bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>(
      "canGetScannedNetworks",
      {"askPermissions": askPermissions},
    );
    return _deserializeCanGetScannedNetworks(canCode);
  }

  Future<List<WiFiNetwork>> get scannedNetworks async {
    final scannedNetworks =
        await _channel.invokeListMethod<Map>("scannedNetworks");
    return scannedNetworks!
        .map((map) => WiFiNetwork._fromMap(map))
        .toList(growable: false);
  }

  Stream<List<WiFiNetwork>> get scannedNetworksStream =>
      _scannedNetworksStream ??=
          _scannedNetworksChannel.receiveBroadcastStream().map((event) {
        if (event is Error) throw event;
        if (event is List) {
          return event
              .map((map) => WiFiNetwork._fromMap(map))
              .toList(growable: false);
        }
        return const <WiFiNetwork>[];
      });
}
