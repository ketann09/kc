import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_client.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/data/datasources/remote/lots_remote_data_source.dart';
import 'package:kabadiwala_connect/data/models/lot_model.dart';
import 'package:kabadiwala_connect/data/repositories/recycler_lots_repository_impl.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/update_lot_lifecycle_usecase.dart';

class FakeApiClient implements ApiClient {
  String? lastPath;
  dynamic lastData;
  Map<String, dynamic>? responseDataToReturn;
  bool shouldThrow = false;
  ApiException? exceptionToThrow;

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    lastData = data;
    if (shouldThrow) {
      throw exceptionToThrow ??
          ApiException.server(message: 'लॉट स्थिति अपडेट विफल रही');
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseDataToReturn as T?,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLotsRemoteDataSource implements LotsRemoteDataSource {
  String? lastLotId;
  String? lastStatus;
  double? lastActualWeight;
  double? lastFinalPrice;
  LotModel? lotModelToReturn;
  bool shouldThrow = false;
  Exception? exceptionToThrow;

  @override
  Future<LotModel> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) async {
    lastLotId = lotId;
    lastStatus = status;
    lastActualWeight = actualWeight;
    lastFinalPrice = finalPrice;
    if (shouldThrow) {
      throw exceptionToThrow ?? Exception('Remote data source error');
    }
    return lotModelToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRecyclerLotsRepo implements RecyclerLotsRepository {
  String? lastLotId;
  String? lastStatus;
  double? lastActualWeight;
  double? lastFinalPrice;
  LotEntity? lotEntityToReturn;
  bool shouldThrow = false;
  Exception? exceptionToThrow;

  @override
  Future<LotEntity> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) async {
    lastLotId = lotId;
    lastStatus = status;
    lastActualWeight = actualWeight;
    lastFinalPrice = finalPrice;
    if (shouldThrow) {
      throw exceptionToThrow ?? Exception('Repository error');
    }
    return lotEntityToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LotsRemoteDataSourceImpl.updateLotLifecycle Tests', () {
    late FakeApiClient fakeApiClient;
    late LotsRemoteDataSourceImpl dataSource;

    final backendSuccessResponse = {
      'statusCode': 200,
      'data': {
        '_id': 'lot-abc-123',
        'collectorId': {
          '_id': 'col-1',
          'fullName': 'रमेश कुमार',
          'phoneNumber': '9876543210',
        },
        'recyclerId': {
          '_id': 'rec-1',
          'fullName': 'ग्रीन रीसाइक्लर्स',
          'phoneNumber': '9123456780',
        },
        'materialId': {
          '_id': 'mat-1',
          'name': 'कॉपर वायर',
        },
        'status': 'picked',
        'estimatedWeight': 25.0,
        'estimatedPrice': 12500.0,
        'actualPickupTime': '2026-09-17T20:00:00.000Z',
        'location': {
          'address': 'सेक्टर 62, नोएडा',
          'city': 'नोएडा',
          'state': 'उत्तर प्रदेश',
        },
        'createdAt': '2026-09-17T12:00:00.000Z',
      },
      'message': 'Lot status updated successfully',
      'success': true,
    };

    setUp(() {
      fakeApiClient = FakeApiClient();
      dataSource = LotsRemoteDataSourceImpl(apiClient: fakeApiClient);
    });

    test('1. Calls correct PATCH endpoint /lots/:lotId', () async {
      fakeApiClient.responseDataToReturn = backendSuccessResponse;

      await dataSource.updateLotLifecycle(
        lotId: 'lot-abc-123',
        status: 'picked',
      );

      expect(fakeApiClient.lastPath, '/lots/lot-abc-123');
    });

    test('2. Correct payload when optional fields are absent', () async {
      fakeApiClient.responseDataToReturn = backendSuccessResponse;

      await dataSource.updateLotLifecycle(
        lotId: 'lot-abc-123',
        status: 'picked',
      );

      expect(fakeApiClient.lastData, {
        'status': 'picked',
      });
      expect(fakeApiClient.lastData.containsKey('actualWeight'), isFalse);
      expect(fakeApiClient.lastData.containsKey('finalPrice'), isFalse);
    });

    test('3. Correct payload when actualWeight and finalPrice are provided', () async {
      fakeApiClient.responseDataToReturn = {
        'statusCode': 200,
        'data': {
          ...backendSuccessResponse['data'] as Map<String, dynamic>,
          'status': 'completed',
          'actualWeight': 26.5,
          'finalPrice': 13250.0,
          'completedAt': '2026-09-17T20:30:00.000Z',
        },
        'message': 'Lot status updated successfully',
        'success': true,
      };

      await dataSource.updateLotLifecycle(
        lotId: 'lot-abc-123',
        status: 'completed',
        actualWeight: 26.5,
        finalPrice: 13250.0,
      );

      expect(fakeApiClient.lastData, {
        'status': 'completed',
        'actualWeight': 26.5,
        'finalPrice': 13250.0,
      });
    });

    test('4. Correctly parses real backend response into LotModel', () async {
      fakeApiClient.responseDataToReturn = {
        'statusCode': 200,
        'data': {
          '_id': 'lot-abc-123',
          'collectorId': {
            '_id': 'col-1',
            'fullName': 'रमेश कुमार',
            'phoneNumber': '9876543210',
          },
          'materialId': {
            '_id': 'mat-1',
            'name': 'कॉपर वायर',
          },
          'status': 'delivered',
          'estimatedWeight': 25.0,
          'actualWeight': 25.0,
          'estimatedPrice': 12500.0,
          'finalPrice': 12500.0,
          'location': {
            'address': 'सेक्टर 62, नोएडा',
            'city': 'नोएडा',
            'state': 'उत्तर प्रदेश',
          },
        },
        'message': 'Lot status updated successfully',
        'success': true,
      };

      final result = await dataSource.updateLotLifecycle(
        lotId: 'lot-abc-123',
        status: 'delivered',
        actualWeight: 25.0,
      );

      expect(result, isA<LotModel>());
      expect(result.id, 'lot-abc-123');
      expect(result.status, LotStatus.delivered);
      expect(result.collectorName, 'रमेश कुमार');
      expect(result.materialName, 'कॉपर वायर');
      expect(result.estimatedWeight, 25.0);
      expect(result.actualWeight, 25.0);
      expect(result.finalPrice, 12500.0);
      expect(result.location.city, 'नोएडा');
    });

    test('5. Propagates API error when PATCH request fails', () async {
      fakeApiClient.shouldThrow = true;
      fakeApiClient.exceptionToThrow = ApiException.server(
        message: 'You are not authorized to update this lot',
        statusCode: 403,
      );

      expect(
        () => dataSource.updateLotLifecycle(
          lotId: 'lot-abc-123',
          status: 'picked',
        ),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'You are not authorized to update this lot',
        )),
      );
    });
  });

  group('RecyclerLotsRepositoryImpl.updateLotLifecycle Tests', () {
    late FakeLotsRemoteDataSource fakeDataSource;
    late RecyclerLotsRepositoryImpl repository;

    final sampleLotModel = LotModel(
      id: 'lot-repo-1',
      collectorId: 'col-1',
      materialName: 'प्लास्टिक',
      estimatedWeight: 10.0,
      actualWeight: 10.5,
      estimatedPrice: 200.0,
      finalPrice: 210.0,
      status: LotStatus.completed,
    );

    setUp(() {
      fakeDataSource = FakeLotsRemoteDataSource();
      repository = RecyclerLotsRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('6. Delegates updateLotLifecycle to remote data source and returns LotEntity', () async {
      fakeDataSource.lotModelToReturn = sampleLotModel;

      final result = await repository.updateLotLifecycle(
        lotId: 'lot-repo-1',
        status: 'completed',
        actualWeight: 10.5,
        finalPrice: 210.0,
      );

      expect(fakeDataSource.lastLotId, 'lot-repo-1');
      expect(fakeDataSource.lastStatus, 'completed');
      expect(fakeDataSource.lastActualWeight, 10.5);
      expect(fakeDataSource.lastFinalPrice, 210.0);
      expect(result, isA<LotEntity>());
      expect(result.id, 'lot-repo-1');
      expect(result.status, LotStatus.completed);
      expect(result.actualWeight, 10.5);
    });

    test('7. Propagates exception from remote data source', () async {
      fakeDataSource.shouldThrow = true;
      fakeDataSource.exceptionToThrow = Exception('Data source failed');

      expect(
        () => repository.updateLotLifecycle(
          lotId: 'lot-repo-1',
          status: 'picked',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('UpdateLotLifecycleUseCase Tests', () {
    late FakeRecyclerLotsRepo fakeRepo;
    late UpdateLotLifecycleUseCase useCase;

    final sampleLotEntity = const LotEntity(
      id: 'lot-usecase-1',
      collectorId: 'col-1',
      materialName: 'कांच',
      estimatedWeight: 50.0,
      estimatedPrice: 2500.0,
      status: LotStatus.delivered,
    );

    setUp(() {
      fakeRepo = FakeRecyclerLotsRepo();
      useCase = UpdateLotLifecycleUseCase(fakeRepo);
    });

    test('8. Delegates call to RecyclerLotsRepository and returns LotEntity', () async {
      fakeRepo.lotEntityToReturn = sampleLotEntity;

      final result = await useCase(
        lotId: 'lot-usecase-1',
        status: 'delivered',
      );

      expect(fakeRepo.lastLotId, 'lot-usecase-1');
      expect(fakeRepo.lastStatus, 'delivered');
      expect(result, isA<LotEntity>());
      expect(result.id, 'lot-usecase-1');
      expect(result.status, LotStatus.delivered);
    });

    test('9. Propagates exception from repository', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.exceptionToThrow = Exception('Repository failed');

      expect(
        () => useCase(
          lotId: 'lot-usecase-1',
          status: 'delivered',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
