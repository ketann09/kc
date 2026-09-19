import 'package:equatable/equatable.dart';

/// Represents high-level network connection statuses.
enum NetworkStatus {
  /// Active connection to network and backend.
  online,

  /// Network or backend is unavailable / unreachable.
  offline,

  /// Connection was recently restored after an offline period.
  restored,
}

/// State managed by [NetworkCubit] representing real-time application connectivity.
class NetworkState extends Equatable {
  final NetworkStatus status;
  final String? message;
  final DateTime timestamp;

  const NetworkState({
    required this.status,
    this.message,
    required this.timestamp,
  });

  /// Whether network is currently usable (either stable online or recently restored).
  bool get isOnline =>
      status == NetworkStatus.online || status == NetworkStatus.restored;

  /// Whether network or backend is unreachable.
  bool get isOffline => status == NetworkStatus.offline;

  /// Whether connectivity was just restored from an offline state.
  bool get isRestored => status == NetworkStatus.restored;

  factory NetworkState.initial({bool isOnline = true}) => NetworkState(
    status: isOnline ? NetworkStatus.online : NetworkStatus.offline,
    timestamp: DateTime.now(),
  );

  factory NetworkState.online() =>
      NetworkState(status: NetworkStatus.online, timestamp: DateTime.now());

  factory NetworkState.offline({String? message}) => NetworkState(
    status: NetworkStatus.offline,
    message: message,
    timestamp: DateTime.now(),
  );

  factory NetworkState.restored() =>
      NetworkState(status: NetworkStatus.restored, timestamp: DateTime.now());

  NetworkState copyWith({
    NetworkStatus? status,
    String? message,
    DateTime? timestamp,
  }) {
    return NetworkState(
      status: status ?? this.status,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
