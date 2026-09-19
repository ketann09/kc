import 'dart:async';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/api_exception.dart';

/// Central abstraction for monitoring network connectivity and backend reachability.
abstract class ConnectivityService {
  /// Stream emitting connectivity status changes (`true` for online/reachable, `false` for offline).
  Stream<bool> get onConnectivityChanged;

  /// Current reachability status based on the latest probe or telemetry.
  bool get isOnline;

  /// Explicitly probes connectivity (e.g. backend `/healthcheck` or custom probe).
  Future<bool> checkConnection();

  /// Passively reports a network request outcome from ApiClient.
  void recordTelemetry({required bool isSuccess, ApiException? exception});

  /// Disposes background probe timers and streams.
  void dispose();
}

/// Production implementation of [ConnectivityService] using active healthcheck
/// probing and passive [ApiClient] telemetry.
class DefaultConnectivityService implements ConnectivityService {
  final ApiClient? apiClient;
  final Future<bool> Function()? customProbe;
  final Dio _probeDio;
  final Duration probeInterval;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  Timer? _periodicTimer;
  bool _isOnline;
  bool _isDisposed = false;

  DefaultConnectivityService({
    this.apiClient,
    this.customProbe,
    Dio? probeDio,
    this.probeInterval = const Duration(seconds: 30),
    bool autoStartProbe = false,
    bool initialOnline = true,
  })  : _probeDio = probeDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 4),
              ),
            ),
        _isOnline = initialOnline {
    // Attach passive telemetry listener to ApiClient if provided
    apiClient?.addTelemetryListener(_onApiTelemetry);

    if (autoStartProbe) {
      startPeriodicProbe();
    }
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  bool get isOnline => _isOnline;

  /// Starts periodic probing at the configured interval.
  void startPeriodicProbe() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(probeInterval, (_) {
      checkConnection();
    });
  }

  /// Stops the periodic probe timer.
  void stopPeriodicProbe() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  @override
  Future<bool> checkConnection() async {
    if (_isDisposed) return _isOnline;

    bool reached;

    if (customProbe != null) {
      try {
        reached = await customProbe!();
      } catch (_) {
        reached = false;
      }
    } else {
      reached = await _probeBackendHealth();
    }

    _updateOnlineStatus(reached);
    return reached;
  }

  Future<bool> _probeBackendHealth() async {
    if (!ApiConfig.isConfigured) {
      // In local testing or environments without defined API_BASE_URL, default to online
      return true;
    }

    try {
      final endpoint = '${ApiConfig.baseUrl}/healthcheck';
      final response = await _probeDio.get(
        endpoint,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _onApiTelemetry(bool isSuccess, {ApiException? exception}) {
    recordTelemetry(isSuccess: isSuccess, exception: exception);
  }

  @override
  void recordTelemetry({required bool isSuccess, ApiException? exception}) {
    if (_isDisposed) return;

    if (isSuccess) {
      _updateOnlineStatus(true);
    } else if (exception != null) {
      // If the error was a socket/network unreachable or timeout error, transition to offline
      if (exception.isNetworkError || exception.isTimeout) {
        _updateOnlineStatus(false);
      }
    }
  }

  void _updateOnlineStatus(bool newStatus) {
    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      if (!_controller.isClosed) {
        _controller.add(newStatus);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _periodicTimer?.cancel();
    _periodicTimer = null;
    apiClient?.removeTelemetryListener(_onApiTelemetry);
    _controller.close();
  }
}
