import 'wifi_connect_codes.dart';

/// The outcome of a Wi-Fi connection operation.
///
/// With `withInternet: true` on Android 10 or later, success means the network
/// suggestion was accepted. The system decides whether and when to connect.
/// Otherwise, success means the platform reported a connection to the network.
class WiFiConnectResult {
  /// Creates a connection result with a stable [code] and optional native details.
  const WiFiConnectResult({
    required this.code,
    this.nativeCode,
    this.nativeDomain,
    this.message,
  });

  /// A stable error code from [WiFiConnectCode], or [WiFiConnectCode.ok].
  final String code;

  /// The original platform error or status code, when available.
  ///
  /// This is an integer for Android suggestion statuses and iOS NSError codes,
  /// or a string for errors delivered as a Flutter PlatformException.
  final Object? nativeCode;

  /// The native NSError domain or Android API/exception class, when available.
  final String? nativeDomain;

  /// The platform's error message, when available. It may be localized.
  final String? message;

  /// Whether the operation succeeded, subject to the platform semantics above.
  bool get isSuccess => code == WiFiConnectCode.ok;
}
