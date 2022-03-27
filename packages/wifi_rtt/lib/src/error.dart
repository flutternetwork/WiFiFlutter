part of '../wifi_rtt.dart';

enum RangingErrors {
  /// Functionality is not supported.
  notSupported,

  /// Functionality is not avialable at this point.
  ///
  /// This could be because of multiple reasons - WiFi disabled, SoftAP or
  /// tethering are in use, etc.
  notAvailable,

  /// Location permission is required.
  ///
  /// A prompt for permission can be requested.
  locationPermissionRequired,

  /// Location permission is denied.
  ///
  /// Need to ask user to manually allow from settings.
  locationPermissionDenied,

  /// Location permission accuracy needs to be upgraded.
  ///
  /// Need to ask user to manually allow from settings.
  locationPermissionUpgradeAccuracy,

  /// Location service needs to be enabled.
  locationServiceDisabled,

  /// Ranging operation failed.
  failed,
}

RangingErrors _deserializeRangingError(int errorCode) {
  switch (errorCode) {
    case 0:
      return RangingErrors.notSupported;
    case 1:
      return RangingErrors.notAvailable;
    case 2:
      return RangingErrors.locationPermissionRequired;
    case 3:
      return RangingErrors.locationPermissionDenied;
    case 4:
      return RangingErrors.locationPermissionUpgradeAccuracy;
    case 5:
      return RangingErrors.failed;
    default:
      throw UnsupportedError(
          "$errorCode cannot be serialized to RangingErrors");
  }
}
