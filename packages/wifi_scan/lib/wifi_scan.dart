import 'dart:async';

import 'package:flutter/services.dart';

part 'src/accesspoint.dart';

part 'src/can.dart';

/// The `wifi_scan` plugin entry point.
///
/// To get a new instance, call [WiFiScan.instance].
class WiFiScan {
  WiFiScan._();

  /// Singleton instance of [WiFiScan].
  static final instance = WiFiScan._();

  final _channel = const MethodChannel('wifi_scan');
  final _scannedResultsAvailableChannel =
      const EventChannel('wifi_scan/onScannedResultsAvailable');
  Stream<List<WiFiAccessPoint>>? _onScannedResultsAvailable;

  /// Checks if it is ok to invoke [startScan].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>("canStartScan", {
      "askPermissions": askPermissions,
    });
    return _deserializeCanStartScan(canCode);
  }

  /// Request a Wi-Fi scan.
  ///
  /// Return value indicates if the "scan" trigger successed.
  ///
  /// Should call [canStartScan] as a check before calling this method.
  Future<bool> startScan() async {
    final isSucess = await _channel.invokeMethod<bool>("startScan");
    return isSucess!;
  }

  /// Checks if it is ok to invoke [getScannedResults] or [onScannedResultsAvailable].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanGetScannedResults> canGetScannedResults(
      {bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>("canGetScannedResults", {
      "askPermissions": askPermissions,
    });
    return _deserializeCanGetScannedResults(canCode);
  }

  /// Get scanned access point.
  ///
  /// This are cached accesss points from most recently performed scan.
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Future<List<WiFiAccessPoint>> getScannedResults() async {
    final scannedResults =
        await _channel.invokeListMethod<Map>("getScannedResults");
    return scannedResults!
        .map((map) => WiFiAccessPoint._fromMap(map))
        .toList(growable: false);
  }

  /// Fires whenever new scanned results are available.
  ///
  /// New results are added to stream when platform performs the scan, either by
  /// itself or trigger with [startScan].
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Stream<List<WiFiAccessPoint>> get onScannedResultsAvailable =>
      _onScannedResultsAvailable ??=
          _scannedResultsAvailableChannel.receiveBroadcastStream().map((event) {
        if (event is Error) throw event;
        if (event is List) {
          return event
              .map((map) => WiFiAccessPoint._fromMap(map))
              .toList(growable: false);
        }
        return const <WiFiAccessPoint>[];
      });
}
