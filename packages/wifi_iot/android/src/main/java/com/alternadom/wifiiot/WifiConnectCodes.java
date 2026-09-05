package com.alternadom.wifiiot;

/**
 * Unified Wi-Fi connect result codes; values must match {@code lib/wifi_connect_codes.dart} and
 * iOS {@code WifiConnectCodes.swift}. Empty string means success.
 */
public final class WifiConnectCodes {
  private WifiConnectCodes() {}

  public static final String OK = "";

  public static final String INVALID_SSID = "invalid_ssid";

  public static final String INVALID_BSSID = "invalid_bssid";
  public static final String WEP_NOT_SUPPORTED = "wep_not_supported";
  public static final String UNKNOWN = "unknown";

  public static final String NETWORK_CONFIGURATION_FAILED = "network_configuration_failed";
  public static final String DISCONNECT_FAILED = "disconnect_failed";
  public static final String ENABLE_NETWORK_FAILED = "enable_network_failed";
  public static final String CONNECTION_TIMEOUT = "connection_timeout";
  public static final String CONNECTION_UNAVAILABLE = "connection_unavailable";

  public static final String NETWORK_SUGGESTION_INTERNAL = "network_suggestion_internal";
  public static final String NETWORK_SUGGESTION_APP_DISALLOWED = "network_suggestion_app_disallowed";
  public static final String NETWORK_SUGGESTION_DUPLICATE = "network_suggestion_duplicate";
  public static final String NETWORK_SUGGESTION_EXCEEDS_MAX_PER_APP =
      "network_suggestion_exceeds_max_per_app";
  public static final String NETWORK_SUGGESTION_REMOVE_INVALID = "network_suggestion_remove_invalid";
  public static final String NETWORK_SUGGESTION_ADD_NOT_ALLOWED = "network_suggestion_add_not_allowed";
  public static final String NETWORK_SUGGESTION_INVALID = "network_suggestion_invalid";
  public static final String NETWORK_SUGGESTION_RESTRICTED_BY_ADMIN =
      "network_suggestion_restricted_by_admin";
  public static final String NETWORK_SUGGESTION_FAILED = "network_suggestion_failed";
}
