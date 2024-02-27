import 'package:flutter/services.dart';
import 'package:wifi_scan/wifi_scan.dart';

class MethodChannelWifiScan extends WiFiScan {
  final _channel = const MethodChannel('wifi_scan');
  final _scannedResultsAvailableChannel =
  const EventChannel('wifi_scan/onScannedResultsAvailable');
  Stream<List<WiFiAccessPoint>>? _onScannedResultsAvailable;

  @override
  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>("canStartScan", {
      "askPermissions": askPermissions,
    });
    return deserializeCanStartScan(canCode);
  }

  @override
  Future<bool> startScan() async {
    final isSucess = await _channel.invokeMethod<bool>("startScan");
    return isSucess!;
  }

  @override
  Future<CanGetScannedResults> canGetScannedResults(
      {bool askPermissions = true}) async {
    final canCode = await _channel.invokeMethod<int>("canGetScannedResults", {
      "askPermissions": askPermissions,
    });
    return deserializeCanGetScannedResults(canCode);
  }

  @override
  Future<List<WiFiAccessPoint>> getScannedResults() async {
    final scannedResults =
    await _channel.invokeListMethod<Map>("getScannedResults");
    return scannedResults!
        .map((map) => WiFiAccessPoint.fromMap(map))
        .toList(growable: false);
  }

  @override
  Stream<List<WiFiAccessPoint>> get onScannedResultsAvailable =>
      _onScannedResultsAvailable ??=
          _scannedResultsAvailableChannel.receiveBroadcastStream().map((event) {
            if (event is Error) throw event;
            if (event is List) {
              return event
                  .map((map) => WiFiAccessPoint.fromMap(map))
                  .toList(growable: false);
            }
            return const <WiFiAccessPoint>[];
          });
}