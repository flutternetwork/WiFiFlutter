part of '../wifi_rtt.dart';

enum CanRequestRanging {
  /// Functionality is not supported.
  notSupported,

  /// It is ok to call the functionality.
  yes,

  /// Functionality is not avialable at this point.
  ///
  /// This could be because of multiple reasons - WiFi disabled, SoftAP or
  /// tethering are in use, etc.
  noUnavailable,

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

CanRequestRanging _deserializeCanRequestRanging(int? canCode) {
  switch (canCode) {
    case 0:
      return CanRequestRanging.notSupported;
    case 1:
      return CanRequestRanging.yes;
    case 2:
      return CanRequestRanging.noUnavailable;
    case 3:
      return CanRequestRanging.noLocationPermissionRequired;
    case 4:
      return CanRequestRanging.noLocationPermissionDenied;
    case 5:
      return CanRequestRanging.noLocationPermissionUpgradeAccuracy;
    default:
      throw UnsupportedError(
          "$canCode cannot be deserialized to CanRequestRanging");
  }
}
