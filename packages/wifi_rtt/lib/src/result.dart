part of '../wifi_rtt.dart';

/// Represents either value or error.
class Result<ValueType, ErrorType> {
  /// Data.
  final ValueType? value;

  /// Error.
  final ErrorType? error;

  const Result._error(this.error) : value = null;

  const Result._value(this.value) : error = null;

  /// Convenient getter to check if holds error.
  bool get hasError => error != null;
}

class WiFiRangingResult {
  WiFiRangingResult._fromMap(Map map) {
    // TODO
  }
}