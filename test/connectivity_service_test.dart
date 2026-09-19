import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_client.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/services/connectivity_service.dart';

void main() {
  group('DefaultConnectivityService Tests', () {
    test('starts with initialOnline value', () {
      final serviceOnline = DefaultConnectivityService(initialOnline: true);
      expect(serviceOnline.isOnline, isTrue);
      serviceOnline.dispose();

      final serviceOffline = DefaultConnectivityService(initialOnline: false);
      expect(serviceOffline.isOnline, isFalse);
      serviceOffline.dispose();
    });

    test('checkConnection delegates to customProbe and emits transition',
        () async {
      bool probeResult = true;
      final service = DefaultConnectivityService(
        initialOnline: true,
        customProbe: () async => probeResult,
      );

      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      // Probe returns true (no change, already true)
      final res1 = await service.checkConnection();
      await pumpEventQueue();
      expect(res1, isTrue);
      expect(emissions, isEmpty);

      // Probe returns false (changes status)
      probeResult = false;
      final res2 = await service.checkConnection();
      await pumpEventQueue();
      expect(res2, isFalse);
      expect(service.isOnline, isFalse);
      expect(emissions, [false]);

      // Probe returns true again (recovery)
      probeResult = true;
      final res3 = await service.checkConnection();
      await pumpEventQueue();
      expect(res3, isTrue);
      expect(service.isOnline, isTrue);
      expect(emissions, [false, true]);

      await sub.cancel();
      service.dispose();
    });

    test(
        'recordTelemetry(isSuccess: false) with network error transitions to offline',
        () async {
      final service = DefaultConnectivityService(initialOnline: true);
      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      service.recordTelemetry(
        isSuccess: false,
        exception: ApiException.network(),
      );
      await pumpEventQueue();

      expect(service.isOnline, isFalse);
      expect(emissions, [false]);

      await sub.cancel();
      service.dispose();
    });

    test(
        'recordTelemetry(isSuccess: false) with timeout transitions to offline',
        () async {
      final service = DefaultConnectivityService(initialOnline: true);
      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      service.recordTelemetry(
        isSuccess: false,
        exception: ApiException.timeout(),
      );
      await pumpEventQueue();

      expect(service.isOnline, isFalse);
      expect(emissions, [false]);

      await sub.cancel();
      service.dispose();
    });

    test(
        'recordTelemetry with 4xx/auth/server error does NOT mark network as offline',
        () async {
      final service = DefaultConnectivityService(initialOnline: true);
      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      // 401 Unauthorized means backend is reached
      service.recordTelemetry(
        isSuccess: false,
        exception: ApiException.unauthorized(),
      );
      await pumpEventQueue();
      expect(service.isOnline, isTrue);
      expect(emissions, isEmpty);

      // 500 Server error means backend is reached
      service.recordTelemetry(
        isSuccess: false,
        exception: ApiException.server(),
      );
      await pumpEventQueue();
      expect(service.isOnline, isTrue);
      expect(emissions, isEmpty);

      await sub.cancel();
      service.dispose();
    });

    test('recordTelemetry(isSuccess: true) restores online status', () async {
      final service = DefaultConnectivityService(initialOnline: false);
      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      service.recordTelemetry(isSuccess: true);
      await pumpEventQueue();

      expect(service.isOnline, isTrue);
      expect(emissions, [true]);

      await sub.cancel();
      service.dispose();
    });

    test('listens to ApiClient telemetry callbacks automatically', () async {
      final apiClient = ApiClient();
      final service = DefaultConnectivityService(
        apiClient: apiClient,
        initialOnline: true,
      );

      final emissions = <bool>[];
      final sub = service.onConnectivityChanged.listen(emissions.add);

      // Simulate a network failure via ApiClient telemetry hook
      service.recordTelemetry(
        isSuccess: false,
        exception: ApiException.network(),
      );
      await pumpEventQueue();
      expect(service.isOnline, isFalse);
      expect(emissions, [false]);

      // Simulate a success via ApiClient telemetry hook
      service.recordTelemetry(isSuccess: true);
      await pumpEventQueue();
      expect(service.isOnline, isTrue);
      expect(emissions, [false, true]);

      await sub.cancel();
      service.dispose();
    });
  });
}
