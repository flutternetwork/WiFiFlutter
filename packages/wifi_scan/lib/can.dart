part of 'wifi_scan.dart';

enum CanStartScan {
  notSupported,
  yes,
  noLocationPermissionRequired,
  noLocationPermissionDenied,
  noLocationServiceDisabled,
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
      return CanStartScan.noLocationServiceDisabled;
  }
  throw UnsupportedError("$canCode cannot be serialized to CanStartScan");
}

enum CanGetScannedNetworks {
  notSupported,
  yes,
  noLocationPermissionRequired,
  noLocationPermissionDenied,
  noLocationServiceDisabled,
}

CanGetScannedNetworks _deserializeCanGetScannedNetworks(int? canCode) {
  switch (canCode) {
    case 0:
      return CanGetScannedNetworks.notSupported;
    case 1:
      return CanGetScannedNetworks.yes;
    case 2:
      return CanGetScannedNetworks.noLocationPermissionRequired;
    case 3:
      return CanGetScannedNetworks.noLocationPermissionDenied;
    case 4:
      return CanGetScannedNetworks.noLocationServiceDisabled;
  }
  throw UnsupportedError(
      "$canCode cannot be serialized to CanGetScannedNetworks");
}
