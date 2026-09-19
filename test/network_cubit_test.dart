import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/bloc/network/network_cubit.dart';
import 'package:kabadiwala_connect/core/bloc/network/network_state.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/services/connectivity_service.dart';

class FakeConnectivityService implements ConnectivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isOnline;
  bool checkConnectionCalled = false;

  FakeConnectivityService({bool initialOnline = true})
    : _isOnline = initialOnline;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  bool get isOnline => _isOnline;

  @override
  Future<bool> checkConnection() async {
    checkConnectionCalled = true;
    return _isOnline;
  }

  @override
  void recordTelemetry({required bool isSuccess, ApiException? exception}) {
    if (isSuccess) {
      setOnline(true);
    } else if (exception?.isNetworkError == true ||
        exception?.isTimeout == true) {
      setOnline(false);
    }
  }

  void setOnline(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('NetworkCubit Tests', () {
    test('initial state reflects connectivityService.isOnline', () {
      final fakeOnline = FakeConnectivityService(initialOnline: true);
      final cubitOnline = NetworkCubit(connectivityService: fakeOnline);
      expect(cubitOnline.state.status, equals(NetworkStatus.online));
      expect(cubitOnline.state.isOnline, isTrue);
      cubitOnline.close();

      final fakeOffline = FakeConnectivityService(initialOnline: false);
      final cubitOffline = NetworkCubit(connectivityService: fakeOffline);
      expect(cubitOffline.state.status, equals(NetworkStatus.offline));
      expect(cubitOffline.state.isOffline, isTrue);
      cubitOffline.close();
    });

    test(
      'transitions from online to offline when connectivity drops',
      () async {
        final fake = FakeConnectivityService(initialOnline: true);
        final cubit = NetworkCubit(connectivityService: fake);

        final states = <NetworkStatus>[];
        final sub = cubit.stream.map((s) => s.status).listen(states.add);

        fake.setOnline(false);
        await pumpEventQueue();

        expect(states, [NetworkStatus.offline]);
        expect(cubit.state.isOffline, isTrue);

        await sub.cancel();
        await cubit.close();
      },
    );

    test('transitions from offline to restored, then to online after restoration duration', () async {
      final fake = FakeConnectivityService(initialOnline: false);
      final cubit = NetworkCubit(
        connectivityService: fake,
        restorationNoticeDuration: const Duration(milliseconds: 50),
      );

      final statuses = <NetworkStatus>[];
      final sub = cubit.stream.map((s) => s.status).listen(statuses.add);

      // Connection restored
      fake.setOnline(true);
      await pumpEventQueue();

      expect(cubit.state.isRestored, isTrue);
      expect(statuses.contains(NetworkStatus.restored), isTrue);

      // Wait for restoration notice duration
      await Future.delayed(const Duration(milliseconds: 70));

      expect(cubit.state.status, equals(NetworkStatus.online));
      expect(statuses, [NetworkStatus.restored, NetworkStatus.online]);

      await sub.cancel();
      await cubit.close();
    });

    test('checkConnection delegates to connectivityService', () async {
      final fake = FakeConnectivityService(initialOnline: true);
      final cubit = NetworkCubit(connectivityService: fake);

      expect(fake.checkConnectionCalled, isFalse);
      await cubit.checkConnection();
      expect(fake.checkConnectionCalled, isTrue);

      await cubit.close();
    });

    test('ApiException helper getters behave correctly', () {
      final netErr = ApiException.network();
      expect(netErr.isNetworkError, isTrue);
      expect(netErr.isTimeout, isFalse);
      expect(netErr.isServerError, isFalse);
      expect(netErr.isAuthError, isFalse);
      expect(netErr.isBusinessError, isFalse);

      final timeoutErr = ApiException.timeout();
      expect(timeoutErr.isNetworkError, isFalse);
      expect(timeoutErr.isTimeout, isTrue);

      final authErr = ApiException.unauthorized();
      expect(authErr.isAuthError, isTrue);
      expect(authErr.isBusinessError, isFalse);

      final serverErr = ApiException.server();
      expect(serverErr.isServerError, isTrue);
      expect(serverErr.isBusinessError, isFalse);

      const clientErr = ApiException(
        message: 'Invalid weight',
        type: ApiExceptionType.unknown,
        statusCode: 400,
      );
      expect(clientErr.isBusinessError, isTrue);
      expect(clientErr.isServerError, isFalse);
      expect(clientErr.isNetworkError, isFalse);
    });
  });
}
