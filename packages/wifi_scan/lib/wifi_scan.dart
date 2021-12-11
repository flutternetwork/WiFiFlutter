import 'dart:async';

import 'package:flutter/services.dart';
import 'src/extensions.dart';

enum CanStartScan {
  yes,
  notSupported,
  noLocationPermissionRequired,
  noLocationPermissionDenied,
  noLocationServiceDisabled,
}

enum CanGetScannedNetworks {
  yes,
  notSupported,
  noLocationPermissionRequired,
  noLocationPermissionDenied,
  noLocationServiceDisabled,
}

class WiFiNetwork {
  WiFiNetwork._fromMap(Map map);
}

class WiFiScan {
  WiFiScan._();

  static final instance = WiFiScan._();
  final _channel = const MethodChannel('wifi_scan');
  final _scannedNetworksChannel =
      const EventChannel('wifi_scan/scannedNetworksEvent');
  Stream<List<WiFiNetwork>>? _scannedNetworksStream;

  Future<CanStartScan> canStartScan({bool askPermissions = true}) async =>
      (await _channel.invokeMethod<int>("canStartScan"))!.toCanStartScan();

  Future<bool> startScan() async => await _channel.invokeMethod("startScan");

  Future<CanGetScannedNetworks> canGetScannedNetworks(
          {bool askPermissions = true}) async =>
      (await _channel.invokeMethod<int>("canGetScannedNetworks"))!
          .toCanGetScannedNetworks();

  Future<List<WiFiNetwork>> get scannedNetworks async =>
      (await _channel.invokeListMethod<Map>("scannedNetworks"))!
          .map((map) => WiFiNetwork._fromMap(map))
          .toList(growable: false);

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
