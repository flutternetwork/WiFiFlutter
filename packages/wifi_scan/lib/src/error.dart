part of '../wifi_scan.dart';

/// Possible errors for [WiFiScan.startScan] method.
enum StartScanErrors {
  /// Functionality is not supported.
  notSupported,

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

StartScanErrors _deserializeStartScanError(int errorCode) {
  switch (errorCode) {
    case 0:
      return StartScanErrors.notSupported;
    case 1:
      return StartScanErrors.noLocationPermissionRequired;
    case 2:
      return StartScanErrors.noLocationPermissionDenied;
    case 3:
      return StartScanErrors.noLocationPermissionUpgradeAccuracy;
    case 4:
      return StartScanErrors.noLocationServiceDisabled;
    case 5:
      return StartScanErrors.failed;
  }
  throw UnsupportedError("$errorCode cannot be serialized to StartScanError");
}

/// Possible errors for [WiFiScan.getScannedResults] and
/// [WiFiScan.onScannedResultsAvailable] methods.
enum GetScannedResultsErrors {
  /// Functionality is not the supported.
  notSupported,

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

GetScannedResultsErrors _deserializeGetScannedResultsError(int errorCode) {
  switch (errorCode) {
    case 0:
      return GetScannedResultsErrors.notSupported;
    case 1:
      return GetScannedResultsErrors.noLocationPermissionRequired;
    case 2:
      return GetScannedResultsErrors.noLocationPermissionDenied;
    case 3:
      return GetScannedResultsErrors.noLocationPermissionUpgradeAccuracy;
    case 4:
      return GetScannedResultsErrors.noLocationServiceDisabled;
  }
  throw UnsupportedError(
      "$errorCode cannot be serialized to GetScannedResultsError");
}
