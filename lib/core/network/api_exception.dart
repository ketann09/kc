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

  @override
  String toString() {
    return 'ApiException(type: $type, statusCode: $statusCode, message: $message)';
  }
}
