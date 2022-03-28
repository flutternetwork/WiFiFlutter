part of '../wifi_easy_connect.dart';

/// Possible errors raised when calling [WiFiEasyConnect.onboard].
enum OnboardErrors {
  /// Configurator mode of WiFi Easy Connect (DPP) is not supported.
  notSupported,
}

OnboardErrors _deserializeOnboardingError(int errorCode) {
  switch (errorCode) {
    case 0:
      return OnboardErrors.notSupported;
    default:
      throw UnsupportedError(
          "$errorCode cannot be serialized to OnboardErrors");
  }
}
