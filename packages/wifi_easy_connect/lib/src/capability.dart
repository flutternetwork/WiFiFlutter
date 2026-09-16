part of '../wifi_easy_connect.dart';

/// Possible modes in which Wi-Fi Easy Connect (or DPP) is supported.
enum WiFiEasyConnectCapability {
  /// Wi-Fi Easy Connect (or Device Provisioning Protocol) is not supported.
  none,

  /// Wi-Fi Easy Connect (or Device Provisioning Protocol) is fully supported.
  ///
  /// It is possible to -
  ///   1. Send network credentials to a new device(Configurator mode).
  ///   2. Join a network (Enrollee mode).
  full,

  /// Wi-Fi Easy Connect (or DPP) is supported only as a Configurator.
  ///
  /// It is possible to - send network credentials to a new device.
  configuratorOnly,

  /// Wi-Fi Easy Connect (or DPP) is supported only as a Enrollee.
  ///
  /// It is possible to - join a network.
  enrolleeOnly,
}

WiFiEasyConnectCapability _deserializeCapability(int capabilityCode) {
  switch (capabilityCode) {
    case 0:
      return WiFiEasyConnectCapability.none;
    case 1:
      return WiFiEasyConnectCapability.full;
    case 2:
      return WiFiEasyConnectCapability.configuratorOnly;
    case 3:
      return WiFiEasyConnectCapability.enrolleeOnly;
    default:
      throw UnsupportedError(
          "$capabilityCode cannot be serialized to WiFiEasyConnectCapability");
  }
}
