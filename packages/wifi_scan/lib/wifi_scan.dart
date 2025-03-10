import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wifi_scan/src/wifi_scan_windows.dart';

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

  // StreamController for Windows-specific implementation
  StreamController<List<WiFiAccessPoint>>? _windowsStreamController;
  Timer? _scanTimer;

  /// Checks if it is ok to invoke [startScan].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    if (Platform.isWindows) {
      return _deserializeCanStartScan(1);
    } else {
      final canCode = await _channel.invokeMethod<int>("canStartScan", {
        "askPermissions": askPermissions,
      });
      return _deserializeCanStartScan(canCode);
    }
  }

  /// Request a Wi-Fi scan.
  ///
  /// Return value indicates if the "scan" trigger successed.
  ///
  /// Should call [canStartScan] as a check before calling this method.
  Future<bool> startScan() async {
    if (Platform.isWindows) {
      /* scan at getScannedResults */
      return await windowsStartScan(); // 启动扫描
    } else {
      final isSucess = await _channel.invokeMethod<bool>("startScan");
      return isSucess!;
    }
  }

  /// Checks if it is ok to invoke [getScannedResults] or [onScannedResultsAvailable].
  ///
  /// Necesearry platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanGetScannedResults> canGetScannedResults(
      {bool askPermissions = true}) async {
    if (Platform.isWindows) {
      return _deserializeCanGetScannedResults(1);
    } else {
      final canCode = await _channel.invokeMethod<int>("canGetScannedResults", {
        "askPermissions": askPermissions,
      });
      return _deserializeCanGetScannedResults(canCode);
    }
  }

  /// Get scanned access point.
  ///
  /// This are cached accesss points from most recently performed scan.
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Future<List<WiFiAccessPoint>> getScannedResults() async {
    if (Platform.isWindows) {
      /* using win32 api */
      return windowsGetScanResults();
    } else {
      final scannedResults =
          await _channel.invokeListMethod<Map>("getScannedResults");
      return scannedResults!
          .map((map) => WiFiAccessPoint.fromMap(map))
          .toList(growable: false);
    }
  }

  /// Fires whenever new scanned results are available.
  ///
  /// New results are added to stream when platform performs the scan, either by
  /// itself or trigger with [startScan].
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Stream<List<WiFiAccessPoint>> get onScannedResultsAvailable {
    if (_onScannedResultsAvailable == null) {
      if (Platform.isWindows) {
        // Create a new stream controller for Windows
        _windowsStreamController = StreamController<List<WiFiAccessPoint>>();
        _onScannedResultsAvailable = _windowsStreamController!.stream;

        // Start periodic scanning
        _startWindowsScanning();
      } else {
        _onScannedResultsAvailable = _scannedResultsAvailableChannel
            .receiveBroadcastStream()
            .map((event) {
          if (event is Error) throw event;
          if (event is List) {
            return event
                .map((map) => WiFiAccessPoint.fromMap(map))
                .toList(growable: false);
          }
          return const <WiFiAccessPoint>[];
        });
      }
    }
    return _onScannedResultsAvailable!;
  }

  // Start periodic scanning for Windows
  void _startWindowsScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final success = await windowsStartScan(waitScanDuration: Duration.zero);
      if (success) {
        final results = windowsGetScanResults();
        _windowsStreamController?.add(results);
      }
    });

    // Clean up resources when the stream is canceled
    _windowsStreamController?.onCancel = () {
      _scanTimer?.cancel();
      _scanTimer = null;
      _windowsStreamController?.close();
      _windowsStreamController = null;
      _onScannedResultsAvailable = null;
    };
  }
}
