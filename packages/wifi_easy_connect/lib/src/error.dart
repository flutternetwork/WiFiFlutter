part of '../wifi_easy_connect.dart';

/// Possible errors raised when calling [WiFiEasyConnect.onboard].
enum OnboardErrors {
  /// Configurator mode of WiFi Easy Connect (DPP) is not supported.
  notSupported,
  unknownFailure,
  cancel,
  invalidUri,
  initFailure,
  notCompatible,
  malformedMessage,
  busy,
  timeout,
  protocolFailure,
  invalidNetwork,
  cannotFindNetwork,
  authenticationFailure,
  enrolleeRejected,
}

OnboardErrors _deserializeOnboardingError(int errorCode) {
  switch (errorCode) {
    case 0:
      return OnboardErrors.notSupported;
    case 1:
      return OnboardErrors.unknownFailure;
    case 2:
      return OnboardErrors.cancel;
    case 3:
      return OnboardErrors.invalidUri;
    case 4:
      return OnboardErrors.initFailure;
    case 5:
      return OnboardErrors.notCompatible;
    case 6:
      return OnboardErrors.malformedMessage;
    case 7:
      return OnboardErrors.busy;
    case 8:
      return OnboardErrors.timeout;
    case 9:
      return OnboardErrors.protocolFailure;
    case 10:
      return OnboardErrors.invalidNetwork;
    case 11:
      return OnboardErrors.cannotFindNetwork;
    case 12:
      return OnboardErrors.authenticationFailure;
    case 13:
      return OnboardErrors.enrolleeRejected;
    default:
      return OnboardErrors.unknownFailure;
  }
}

class OnboardError {
  final OnboardErrors error;
  final Map<String, dynamic> info;

  OnboardError._fromMap(Map map)
      : error = _deserializeOnboardingError(map["error"]),
        info = map["data"] ?? {};
}
