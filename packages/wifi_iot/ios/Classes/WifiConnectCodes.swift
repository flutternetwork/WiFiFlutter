import Foundation
import NetworkExtension

/// Unified Wi-Fi connect result codes; values must match `lib/wifi_connect_codes.dart` and Android `WifiConnectCodes.java`. Empty string means success.
enum WifiConnectCodes {
    static let ok = ""
    static let invalidSsid = "invalid_ssid"
    static let invalidBssid = "invalid_bssid"
    static let wepNotSupported = "wep_not_supported"
    static let unknown = "unknown"

    static let networkConfigurationFailed = "network_configuration_failed"
    static let disconnectFailed = "disconnect_failed"
    static let enableNetworkFailed = "enable_network_failed"
    static let connectionTimeout = "connection_timeout"
    static let connectionUnavailable = "connection_unavailable"

    // Android addNetworkSuggestions statuses (same strings for cross-platform handling in Dart)
    static let networkSuggestionInternal = "network_suggestion_internal"
    static let networkSuggestionAppDisallowed = "network_suggestion_app_disallowed"
    static let networkSuggestionDuplicate = "network_suggestion_duplicate"
    static let networkSuggestionExceedsMaxPerApp = "network_suggestion_exceeds_max_per_app"
    static let networkSuggestionRemoveInvalid = "network_suggestion_remove_invalid"
    static let networkSuggestionAddNotAllowed = "network_suggestion_add_not_allowed"
    static let networkSuggestionInvalid = "network_suggestion_invalid"
    static let networkSuggestionRestrictedByAdmin = "network_suggestion_restricted_by_admin"
    static let networkSuggestionFailed = "network_suggestion_failed"

    static let invalidConfiguration = "invalid_configuration"
    static let invalidSsidNative = "invalid_ssid_native"
    static let invalidWpaPassphrase = "invalid_wpa_passphrase"
    static let invalidWepPassphrase = "invalid_wep_passphrase"
    static let invalidEapSettings = "invalid_eap_settings"
    static let invalidHs20Settings = "invalid_hs20_settings"
    static let internalError = "internal_error"
    static let operationPending = "operation_pending"
    static let systemConfigurationError = "system_configuration_error"
    static let unknownError = "unknown_error"
    static let joinOnceNotSupported = "join_once_not_supported"
    static let notInForeground = "not_in_foreground"
    static let userDenied = "user_denied"

    static let postApplySsidUnavailable = "post_apply_ssid_unavailable"
    static let postApplySsidMismatch = "post_apply_ssid_mismatch"

    static let iosVersionUnsupported = "ios_version_unsupported"
    static let pluginInternal = "plugin_internal"

    @available(iOS 11.0, *)
    static func from(neError: NEHotspotConfigurationError) -> String {
        switch neError {
        case .invalid:
            return invalidConfiguration
        case .invalidSSID:
            return invalidSsidNative
        case .invalidWPAPassphrase:
            return invalidWpaPassphrase
        case .invalidWEPPassphrase:
            return invalidWepPassphrase
        case .invalidEAPSettings:
            return invalidEapSettings
        case .invalidHS20Settings:
            return invalidHs20Settings
        case .internal:
            return internalError
        case .pending:
            return operationPending
        case .systemConfiguration:
            return systemConfigurationError
        case .unknown:
            return unknownError
        case .joinOnceNotSupported:
            return joinOnceNotSupported
        case .alreadyAssociated:
            return ok
        case .applicationIsNotInForeground:
            return notInForeground
        case .userDenied:
            return userDenied
        default:
            return unknownError
        }
    }
}
