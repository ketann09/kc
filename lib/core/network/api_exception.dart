enum ApiExceptionType { network, timeout, unauthorized, server, unknown }

class ApiException implements Exception {
  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.data,
  });

  factory ApiException.network({String? message}) {
    return ApiException(
      message:
          message ??
          'इंटरनेट कनेक्शन उपलब्ध नहीं है (Network connection error)',
      type: ApiExceptionType.network,
    );
  }

  factory ApiException.timeout({String? message}) {
    return ApiException(
      message:
          message ??
          'सर्वर से संपर्क करने में अधिक समय लगा (Connection timed out)',
      type: ApiExceptionType.timeout,
    );
  }

  factory ApiException.unauthorized({String? message, dynamic data}) {
    return ApiException(
      message: message ?? 'अनधिकृत अनुरोध (Unauthorized access)',
      type: ApiExceptionType.unauthorized,
      statusCode: 401,
      data: data,
    );
  }

  factory ApiException.server({
    String? message,
    int? statusCode,
    dynamic data,
  }) {
    return ApiException(
      message: message ?? 'सर्वर त्रुटि (Internal server error)',
      type: ApiExceptionType.server,
      statusCode: statusCode ?? 500,
      data: data,
    );
  }

  factory ApiException.unknown({
    String? message,
    int? statusCode,
    dynamic data,
  }) {
    return ApiException(
      message:
          message ?? 'अज्ञात त्रुटि उत्पन्न हुई (An unexpected error occurred)',
      type: ApiExceptionType.unknown,
      statusCode: statusCode,
      data: data,
    );
  }

  /// Whether this exception indicates a client connectivity failure (no network/socket error).
  bool get isNetworkError => type == ApiExceptionType.network;

  /// Whether this exception was caused by a request/connection timeout.
  bool get isTimeout => type == ApiExceptionType.timeout;

  /// Whether this exception was caused by a 5xx backend failure.
  bool get isServerError =>
      type == ApiExceptionType.server ||
      (statusCode != null && statusCode! >= 500);

  /// Whether this exception represents an authentication or authorization failure (401/403).
  bool get isAuthError =>
      type == ApiExceptionType.unauthorized ||
      statusCode == 401 ||
      statusCode == 403;

  /// Whether this exception was caused by a 4xx client/validation error (other than 401/403).
  bool get isBusinessError =>
      statusCode != null &&
      statusCode! >= 400 &&
      statusCode! < 500 &&
      !isAuthError;

  @override
  String toString() {
    return 'ApiException(type: $type, statusCode: $statusCode, message: $message)';
  }
}
