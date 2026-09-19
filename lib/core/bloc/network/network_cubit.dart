import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/connectivity_service.dart';
import 'network_state.dart';

/// Central BLoC/Cubit for tracking network and backend reachability.
class NetworkCubit extends Cubit<NetworkState> {
  final ConnectivityService connectivityService;
  final Duration restorationNoticeDuration;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _restorationTimer;

  NetworkCubit({
    required this.connectivityService,
    this.restorationNoticeDuration = const Duration(seconds: 3),
  }) : super(NetworkState.initial(isOnline: connectivityService.isOnline)) {
    _init();
  }

  void _init() {
    _connectivitySub = connectivityService.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  void _handleConnectivityChange(bool isOnline) {
    _restorationTimer?.cancel();

    if (isOnline) {
      if (state.isOffline) {
        // Transition from offline -> restored (brief visual confirmation)
        emit(NetworkState.restored());
        _restorationTimer = Timer(restorationNoticeDuration, () {
          if (!isClosed && state.isRestored) {
            emit(NetworkState.online());
          }
        });
      } else {
        emit(NetworkState.online());
      }
    } else {
      emit(NetworkState.offline());
    }
  }

  /// Manually triggers an active connectivity probe through [ConnectivityService].
  Future<void> checkConnection() async {
    final reached = await connectivityService.checkConnection();
    _handleConnectivityChange(reached);
  }

  @override
  Future<void> close() {
    _restorationTimer?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}
