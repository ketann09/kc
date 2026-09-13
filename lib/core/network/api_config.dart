class ApiConfig {
  ApiConfig._();

  static const String _rawBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// The standard API version prefix used across all backend endpoints.
  static const String defaultApiPrefix = '/api/v1';

  /// Returns the configured base URL without trailing slashes or duplicate api prefixes.
  /// Throws a [StateError] if API_BASE_URL was not provided via `--dart-define`.
  static String get baseUrl {
    if (_rawBaseUrl.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. '
        'Please launch the app with: --dart-define=API_BASE_URL=<url>\n'
        'Example: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000',
      );
    }

    var url = _rawBaseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    if (url.endsWith(defaultApiPrefix)) {
      url = url.substring(0, url.length - defaultApiPrefix.length);
    }

    return url;
  }

  /// Whether an API_BASE_URL has been supplied via environment.
  static bool get isConfigured => _rawBaseUrl.trim().isNotEmpty;

  /// Default timeout values for network requests.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
