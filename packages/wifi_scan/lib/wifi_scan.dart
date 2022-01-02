import 'dart:async';

import 'package:flutter/services.dart';

part 'src/can.dart';
part 'src/wifi_network.dart';

/// The [WiFiScan] entry point.
///
/// To get a new instance, call [WiFiScan.instance].
class WiFiScan {
  WiFiScan._();

  /// Singleton instance of [WiFiScan].
  static final instance = WiFiScan._();

  final _channel = const MethodChannel('wifi_scan');
  final _scannedNetworksChannel =
      const EventChannel('wifi_scan/scannedNetworksEvent');
  Stream<List<WiFiNetwork>>? _scannedNetworksStream;

  /// Checks if it is ok to call [startScan].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>(
      "canStartScan",
      {"askPermissions": askPermissions},
    );
    return _deserializeCanStartScan(canCode);
  }

  ///
  Future<bool> startScan() async {
    final isSucess = await _channel.invokeMethod<bool>("startScan");
    return isSucess!;
  }

  /// Checks if it is ok to call [scannedNetworks] or [scannedNetworksStream].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanGetScannedNetworks> canGetScannedNetworks(
      {bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>(
      "canGetScannedNetworks",
      {"askPermissions": askPermissions},
    );
    return _deserializeCanGetScannedNetworks(canCode);
  }

  /// Get scanned networks.
  ///
  /// This are cached networks from last scan performed.
  Future<List<WiFiNetwork>> get scannedNetworks async {
    final scannedNetworks =
        await _channel.invokeListMethod<Map>("scannedNetworks");
    return scannedNetworks!
        .map((map) => WiFiNetwork._fromMap(map))
        .toList(growable: false);
  }

  /// Stream of scanned networks.
  ///
  /// New results are added to stream when platform performs the scan, either by
  /// itself or trigger with [startScan].
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
