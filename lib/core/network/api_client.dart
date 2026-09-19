import 'dart:io';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

typedef NetworkTelemetryCallback = void Function(
  bool isSuccess, {
  ApiException? exception,
});

class ApiClient {
  final Dio _dio;
  String? _accessToken;
  final List<NetworkTelemetryCallback> _telemetryListeners = [];

  ApiClient({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  baseUrl ?? (ApiConfig.isConfigured ? ApiConfig.baseUrl : ''),
              connectTimeout: ApiConfig.connectTimeout,
              sendTimeout: ApiConfig.sendTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: {
                Headers.acceptHeader: 'application/json',
                Headers.contentTypeHeader: 'application/json',
              },
              responseType: ResponseType.json,
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach authorization token if present
          if (hasAccessToken) {
            options.headers['Authorization'] = 'Bearer ${_accessToken!.trim()}';
          }

          // Preserve multipart boundaries for FormData uploads
          if (options.data is FormData) {
            options.headers.remove(Headers.contentTypeHeader);
            options.contentType = null;
          }

          return handler.next(options);
        },
      ),
    );
  }

  /// Underlying Dio instance for advanced configurations or testing
  Dio get dio => _dio;

  /// Current authorization access token
  String? get accessToken => _accessToken;

  /// Check whether an active access token is stored
  bool get hasAccessToken =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  /// Register a listener to observe real-time network request outcomes
  void addTelemetryListener(NetworkTelemetryCallback listener) {
    _telemetryListeners.add(listener);
  }

  /// Remove a registered telemetry listener
  void removeTelemetryListener(NetworkTelemetryCallback listener) {
    _telemetryListeners.remove(listener);
  }

  void _notifyTelemetry({required bool isSuccess, ApiException? exception}) {
    for (final listener in List<NetworkTelemetryCallback>.from(
      _telemetryListeners,
    )) {
      try {
        listener(isSuccess, exception: exception);
      } catch (_) {
        // Prevent telemetry listener failures from affecting the caller
      }
    }
  }

  /// Set or update the access token for subsequent requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear the stored access token
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Normalizes path to guarantee it aligns with /api/v1 prefix
  String _normalizePath(String path) {
    if (path.startsWith(ApiConfig.defaultApiPrefix)) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConfig.defaultApiPrefix}$cleanPath';
  }

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        _normalizePath(path),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      _notifyTelemetry(isSuccess: true);
      return response;
    } on DioException catch (e) {
      final apiException = _handleDioException(e);
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    } catch (e) {
      final apiException = ApiException.unknown(message: e.toString());
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    }
  }

  /// Generic POST request (handles both JSON Map and FormData automatically)
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      _notifyTelemetry(isSuccess: true);
      return response;
    } on DioException catch (e) {
      final apiException = _handleDioException(e);
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    } catch (e) {
      final apiException = ApiException.unknown(message: e.toString());
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      _notifyTelemetry(isSuccess: true);
      return response;
    } on DioException catch (e) {
      final apiException = _handleDioException(e);
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    } catch (e) {
      final apiException = ApiException.unknown(message: e.toString());
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    }
  }

  /// Generic PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      _notifyTelemetry(isSuccess: true);
      return response;
    } on DioException catch (e) {
      final apiException = _handleDioException(e);
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    } catch (e) {
      final apiException = ApiException.unknown(message: e.toString());
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      _notifyTelemetry(isSuccess: true);
      return response;
    } on DioException catch (e) {
      final apiException = _handleDioException(e);
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    } catch (e) {
      final apiException = ApiException.unknown(message: e.toString());
      _notifyTelemetry(isSuccess: false, exception: apiException);
      throw apiException;
    }
  }

  /// Centralized mapping from DioException to typed ApiException
  ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException.timeout();

      case DioExceptionType.connectionError:
        return ApiException.network();

      case DioExceptionType.badCertificate:
        return ApiException.network(
          message: 'सुरक्षा प्रमाणपत्र अमान्य है (Bad certificate)',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMessage;

        if (data is Map && data['message'] is String) {
          serverMessage = data['message'] as String;
        }

        if (statusCode == 401 || statusCode == 403) {
          return ApiException.unauthorized(message: serverMessage, data: data);
        }

        if (statusCode != null && statusCode >= 500) {
          return ApiException.server(
            message: serverMessage,
            statusCode: statusCode,
            data: data,
          );
        }

        return ApiException.unknown(
          message: serverMessage ?? error.message,
          statusCode: statusCode,
          data: data,
        );

      case DioExceptionType.cancel:
        return ApiException.unknown(
          message: 'अनुरोध रद्द किया गया (Request cancelled)',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return ApiException.network();
        }
        return ApiException.unknown(
          message: error.message,
          data: error.response?.data,
        );
    }
  }
}
