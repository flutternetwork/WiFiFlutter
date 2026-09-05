// ignore_for_file: package_api_docs, public_member_api_docs

/// Unified Wi‑Fi connect result codes for Flutter, Android, and iOS (`WiFiForIoTPlugin.connect`).
///
/// The native platforms return the same string values. An empty string means success;
/// any non-empty value is an error code.
abstract class WiFiConnectCode {
  WiFiConnectCode._();

  static const String ok = '';

  // Flutter-side validation
  static const String invalidSsid = 'invalid_ssid';

  // Shared / generic
  static const String invalidBssid = 'invalid_bssid';
  static const String wepNotSupported = 'wep_not_supported';
  static const String unknown = 'unknown';
  static const String missingPlugin = 'missing_plugin';

  // Android — configuration & association (deprecated API / supplicant)
  static const String networkConfigurationFailed = 'network_configuration_failed';
  static const String disconnectFailed = 'disconnect_failed';
  static const String enableNetworkFailed = 'enable_network_failed';
  static const String connectionTimeout = 'connection_timeout';
  static const String connectionUnavailable = 'connection_unavailable';

  // Android — WifiManager.addNetworkSuggestions (see [WifiManager] status constants)
  static const String networkSuggestionInternal = 'network_suggestion_internal';
  static const String networkSuggestionAppDisallowed = 'network_suggestion_app_disallowed';
  static const String networkSuggestionDuplicate = 'network_suggestion_duplicate';
  static const String networkSuggestionExceedsMaxPerApp =
      'network_suggestion_exceeds_max_per_app';
  static const String networkSuggestionRemoveInvalid = 'network_suggestion_remove_invalid';
  static const String networkSuggestionAddNotAllowed = 'network_suggestion_add_not_allowed';
  static const String networkSuggestionInvalid = 'network_suggestion_invalid';
  static const String networkSuggestionRestrictedByAdmin =
      'network_suggestion_restricted_by_admin';
  static const String networkSuggestionFailed = 'network_suggestion_failed';

  // iOS — NEHotspotConfigurationError
  static const String invalidConfiguration = 'invalid_configuration';
  static const String invalidSsidNative = 'invalid_ssid_native';
  static const String invalidWpaPassphrase = 'invalid_wpa_passphrase';
  static const String invalidWepPassphrase = 'invalid_wep_passphrase';
  static const String invalidEapSettings = 'invalid_eap_settings';
  static const String invalidHs20Settings = 'invalid_hs20_settings';
  static const String internalError = 'internal_error';
  static const String operationPending = 'operation_pending';
  static const String systemConfigurationError = 'system_configuration_error';
  static const String unknownError = 'unknown_error';
  static const String joinOnceNotSupported = 'join_once_not_supported';
  static const String notInForeground = 'not_in_foreground';
  static const String userDenied = 'user_denied';

  // iOS only: after NEHotspotConfigurationManager.apply succeeds, getSSID verification
  static const String postApplySsidUnavailable = 'post_apply_ssid_unavailable';
  static const String postApplySsidMismatch = 'post_apply_ssid_mismatch';

  static const String iosVersionUnsupported = 'ios_version_unsupported';
  static const String pluginInternal = 'plugin_internal';

  static bool isOk(String code) => code.isEmpty;
}
