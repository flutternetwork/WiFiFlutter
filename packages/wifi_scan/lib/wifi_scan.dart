import 'dart:async';

import 'package:flutter/services.dart';

part 'src/accesspoint.dart';
part 'src/error.dart';
part 'src/result.dart';

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
  Stream<Result<List<WiFiAccessPoint>, GetScannedResultsErrors>>?
      _onScannedResultsAvailable;

  /// Request a Wi-Fi scan.
  ///
  /// Returns null if successful, else [StartScanErrors].
  Future<StartScanErrors?> startScan({bool askPermissions = true}) async {
    final errorCode = await _channel.invokeMethod<int>("startScan", {
      "askPermissions": askPermissions,
    });
    return errorCode == null ? null : _deserializeStartScanError(errorCode);
  }

  Result<List<WiFiAccessPoint>, GetScannedResultsErrors>
      _scannedResultMapToResult(Map map) {
    // check if any error - return Result._error if any
    final errorCode = map["error"];
    if (errorCode != null) {
      return Result._error(_deserializeGetScannedResultsError(errorCode));
    }
    // parse and return list of WiFiAccessPoint
    return Result._value(List<WiFiAccessPoint>.unmodifiable(
        map["value"].map((map) => WiFiAccessPoint._fromMap(map))));
  }

  /// Get scanned access point.
  ///
  /// Returns [Result] object. If successful then [Result.value] is a [List] of
  /// [WiFiAccessPoint] and if failed then [Result.error] is a
  /// [GetScannedResultsErrors] value.
  ///
  /// [Result.value] are cached accesss points from most recently performed scan.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<Result<List<WiFiAccessPoint>, GetScannedResultsErrors>>
      getScannedResults({bool askPermissions = true}) async {
    final resultMap = await _channel.invokeMapMethod("getScannedResults", {
      "askPermissions": askPermissions,
    });
    return _scannedResultMapToResult(resultMap!);
  }

  /// Fires whenever new scanned results are available.
  ///
  /// Each event is of type [Result], where [Result.value] is a [List] of
  /// [WiFiAccessPoint] if fetched successfully or [Result.error] of type
  /// [GetScannedResultsErrors] otherwise.
  ///
  /// Unlike [getScannedResults] required permission are never asked to the user.
  ///
  /// New results are added to stream when platform performs the scan, either by
  /// itself or trigger with [startScan].
  Stream<Result<List<WiFiAccessPoint>, GetScannedResultsErrors>>
      get onScannedResultsAvailable =>
          _onScannedResultsAvailable ??= _scannedResultsAvailableChannel
              .receiveBroadcastStream()
              .map((event) {
            if (event is Map) {
              return _scannedResultMapToResult(event);
            }
            throw UnsupportedError("Unknown event received: $event");
          });
}
