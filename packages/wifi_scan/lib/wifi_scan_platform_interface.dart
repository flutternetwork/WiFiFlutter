import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_scan/src/accesspoint.dart';
import 'package:wifi_scan/src/can.dart';
import 'package:wifi_scan/wifi_scan_method_channel.dart';

abstract class WifiScan extends PlatformInterface {
  WifiScan() : super(token: _token);
  static final Object _token = Object();

  static WifiScan _instance = MethodChannelWifiScan();

  /// The default instance of [WifiScan] to use.
  ///
  /// Defaults to [MethodChannelWifiScan].
  static WifiScan get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [WifiScan] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(WifiScan instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks if it is ok to invoke [startScan].
  ///
  /// Necessary platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanStartScan> canStartScan({bool askPermissions = true}) async {
    throw UnimplementedError('canStartScan() has not been implemented.');
  }

  /// Request a Wi-Fi scan.
  ///
  /// Return value indicates if the "scan" trigger succeeded.
  ///
  /// Should call [canStartScan] as a check before calling this method.
  Future<bool> startScan() async {
    throw UnimplementedError('canStartScan() has not been implemented.');
  }

  /// Checks if it is ok to invoke [getScannedResults] or [onScannedResultsAvailable].
  ///
  /// Necessary platform requirements, like permissions dependent services,
  /// configuration, etc are checked.
  ///
  /// Set [askPermissions] flag to ask user for necessary permissions.
  Future<CanGetScannedResults> canGetScannedResults(
      {bool askPermissions = true}) async {
    throw UnimplementedError('canGetScannedResults() has not been implemented.');
  }

  /// Get scanned access point.
  ///
  /// This are cached access points from most recently performed scan.
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Future<List<WiFiAccessPoint>> getScannedResults() async {
    throw UnimplementedError('getScannedResults() has not been implemented.');
  }

  /// Fires whenever new scanned results are available.
  ///
  /// New results are added to stream when platform performs the scan, either by
  /// itself or trigger with [startScan].
  ///
  /// Should call [canGetScannedResults] as a check before calling this method.
  Stream<List<WiFiAccessPoint>> get onScannedResultsAvailable {
    throw UnimplementedError('onScannedResultsAvailable has not been implemented.');
  }
}