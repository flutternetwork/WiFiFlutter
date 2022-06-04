part of '../wifi_scan.dart';

/// Result for [WiFiScan.canStartScan] method.
enum CanStartScan {
  /// Functionality is not supported.
  notSupported,

  /// It is ok to call the functionality.
  yes,

  /// Location permission is required.
  ///
  /// A prompt for permission can be requested.
  noLocationPermissionRequired,

  /// Location permission is denied.
  ///
  /// Need to ask user to manually allow from settings.
  noLocationPermissionDenied,

  /// Location permission accuracy needs to be upgraded.
  ///
  /// Need to ask user to manually allow from settings.
  noLocationPermissionUpgradeAccuracy,

  /// Location service needs to be enabled.
  noLocationServiceDisabled,

  /// Failed to trigger scan.
  failed,
}

CanStartScan _deserializeCanStartScan(int? canCode) {
  switch (canCode) {
    case 0:
      return CanStartScan.notSupported;
    case 1:
      return CanStartScan.yes;
    case 2:
      return CanStartScan.noLocationPermissionRequired;
    case 3:
      return CanStartScan.noLocationPermissionDenied;
    case 4:
      return CanStartScan.noLocationPermissionUpgradeAccuracy;
    case 5:
      return CanStartScan.noLocationServiceDisabled;
  }
  throw UnsupportedError("$canCode cannot be serialized to CanStartScan");
}

/// Result for [WiFiScan.canGetScannedResults] method.
enum CanGetScannedResults {
  /// Functionality is not the supported.
  notSupported,

  /// It is ok to call functionality.
  yes,

  /// Location permission is required.
  ///
  /// A prompt for permission can be requested.
  noLocationPermissionRequired,

  /// Location permission is denied.
  ///
  /// Need to ask user to manually allow from settings.
  noLocationPermissionDenied,

  /// Location permission accuracy needs to be upgraded.
  ///
  /// Need to ask user to manually allow from settings.
  noLocationPermissionUpgradeAccuracy,

  /// Location service needs to be enabled.
  noLocationServiceDisabled,
}

CanGetScannedResults _deserializeCanGetScannedResults(int? canCode) {
  switch (canCode) {
    case 0:
      return CanGetScannedResults.notSupported;
    case 1:
      return CanGetScannedResults.yes;
    case 2:
      return CanGetScannedResults.noLocationPermissionRequired;
    case 3:
      return CanGetScannedResults.noLocationPermissionDenied;
    case 4:
      return CanGetScannedResults.noLocationPermissionUpgradeAccuracy;
    case 5:
      return CanGetScannedResults.noLocationServiceDisabled;
  }
  throw UnsupportedError(
      "$canCode cannot be serialized to CanGetScannedNetworks");
}
