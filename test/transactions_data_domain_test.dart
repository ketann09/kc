import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_client.dart';
import 'package:kabadiwala_connect/data/datasources/remote/transactions_remote_data_source.dart';
import 'package:kabadiwala_connect/data/models/transaction_model.dart';
import 'package:kabadiwala_connect/data/repositories/transactions_repository_impl.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/create_transaction_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_recycler_transactions_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_handover_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_payment_status_usecase.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super(dio: Dio());

  dynamic responseData;
  int statusCode = 200;
  String? capturedPath;
  dynamic capturedData;
  Map<String, dynamic>? capturedQuery;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    capturedPath = path;
    capturedQuery = queryParameters;
    return Response<T>(
      data: responseData as T,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    capturedPath = path;
    capturedData = data;
    capturedQuery = queryParameters;
    return Response<T>(
      data: responseData as T,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    capturedPath = path;
    capturedData = data;
    capturedQuery = queryParameters;
    return Response<T>(
      data: responseData as T,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }
}

void main() {
  group('TransactionModel Tests', () {
    test('parses populated json correctly', () {
      final json = {
        '_id': 'txn123',
        'lotId': {
          '_id': 'lot456',
          'status': 'completed',
          'estimatedWeight': 100.0,
        },
        'collectorId': {
          '_id': 'col789',
          'fullName': 'Ramesh Kumar',
          'phoneNumber': '9876543210',
          'address': {
            'street': 'Main Street',
            'city': 'Delhi',
            'state': 'Delhi',
          },
        },
        'recyclerId': {
          '_id': 'rec101',
          'fullName': 'Eco Recyclers',
          'phoneNumber': '9123456780',
          'address': 'Industrial Area, Phase 1',
        },
        'amount': 2500,
        'paymentMethod': 'upi',
        'paymentStatus': 'pending',
        'status': 'in_progress',
        'weightDetails': {
          'estimatedWeight': 100.0,
          'actualWeight': 105.0,
          'weightDifference': 5.0,
          'weightUnit': 'kg',
        },
        'commission': {
          'platformFee': 125.0,
          'commissionRate': 5.0,
          'netAmount': 2375.0,
        },
        'handoverDetails': {
          'handoverPhotos': ['https://example.com/photo.jpg'],
          'handoverGPS': {'latitude': 28.6139, 'longitude': 77.2090},
          'receivedBy': 'Ramesh',
          'verifiedBy': 'Suresh',
          'handoverTime': '2026-09-18T10:00:00.000Z',
        },
        'paymentDetails': {
          'transactionId': 'UPI-REF-999',
          'receiptUrl': 'https://example.com/receipt.pdf',
        },
        'notes': 'All good',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, 'txn123');
      expect(model.lotId, 'lot456');
      expect(model.lotStatus, 'completed');
      expect(model.collectorId, 'col789');
      expect(model.collectorName, 'Ramesh Kumar');
      expect(model.collectorPhone, '9876543210');
      expect(model.collectorAddress, contains('Main Street'));
      expect(model.recyclerId, 'rec101');
      expect(model.recyclerName, 'Eco Recyclers');
      expect(model.amount, 2500.0);
      expect(model.paymentMethod, PaymentMethod.upi);
      expect(model.paymentStatus, PaymentStatus.pending);
      expect(model.status, TransactionStatus.inProgress);
      expect(model.commission.platformFee, 125.0);
      expect(model.commission.netAmount, 2375.0);
      expect(model.weightDetails.actualWeight, 105.0);
      expect(model.handoverDetails.isCompleted, true);
      expect(model.handoverDetails.receivedBy, 'Ramesh');
      expect(model.paymentDetails.transactionId, 'UPI-REF-999');
      expect(model.notes, 'All good');

      final serialized = model.toJson();
      expect(serialized['_id'], 'txn123');
      expect(serialized['amount'], 2500.0);
      expect(serialized['paymentMethod'], 'upi');
    });

    test('parses unpopulated string IDs and default fallback values', () {
      final json = {
        '_id': 'txn_simple',
        'lotId': 'lot_simple',
        'collectorId': 'col_simple',
        'recyclerId': 'rec_simple',
        'amount': 500,
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, 'txn_simple');
      expect(model.lotId, 'lot_simple');
      expect(model.collectorId, 'col_simple');
      expect(model.recyclerId, 'rec_simple');
      expect(model.collectorName, isNull);
      expect(model.amount, 500.0);
      expect(model.paymentMethod, PaymentMethod.cash);
      expect(model.paymentStatus, PaymentStatus.pending);
      expect(model.status, TransactionStatus.initiated);
      expect(model.handoverDetails.isCompleted, false);
    });
  });

  group('TransactionsRemoteDataSourceImpl Tests', () {
    late MockApiClient mockApiClient;
    late TransactionsRemoteDataSourceImpl dataSource;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = TransactionsRemoteDataSourceImpl(apiClient: mockApiClient);
    });

    test(
      'createTransaction sends correct payload and parses response',
      () async {
        mockApiClient.responseData = {
          'success': true,
          'data': {
            '_id': 'txn_new',
            'lotId': 'lot_1',
            'collectorId': 'col_1',
            'recyclerId': 'rec_1',
            'amount': 1500,
            'paymentMethod': 'cash',
          },
        };

        final result = await dataSource.createTransaction(
          lotId: 'lot_1',
          paymentMethod: 'cash',
          amount: 1500.0,
          actualWeight: 50.0,
          estimatedWeight: 48.0,
          notes: 'Handover complete',
        );

        expect(mockApiClient.capturedPath, '/transactions');
        expect(mockApiClient.capturedData['lotId'], 'lot_1');
        expect(mockApiClient.capturedData['amount'], 1500.0);
        expect(
          mockApiClient.capturedData['weightDetails']['actualWeight'],
          50.0,
        );
        expect(mockApiClient.capturedData['notes'], 'Handover complete');
        expect(result.id, 'txn_new');
      },
    );

    test('getTransactionById fetches transaction', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          '_id': 'txn_fetch',
          'lotId': 'lot_1',
          'collectorId': 'col_1',
          'recyclerId': 'rec_1',
          'amount': 800,
        },
      };

      final result = await dataSource.getTransactionById('txn_fetch');
      expect(mockApiClient.capturedPath, '/transactions/txn_fetch');
      expect(result.id, 'txn_fetch');
    });

    test('getRecyclerTransactions fetches list', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          'transactions': [
            {
              '_id': 'txn_1',
              'lotId': 'lot_1',
              'collectorId': 'col_1',
              'recyclerId': 'rec_1',
              'amount': 1000,
            },
          ],
        },
      };

      final list = await dataSource.getRecyclerTransactions();
      expect(mockApiClient.capturedPath, '/transactions/recycler');
      expect(list.length, 1);
      expect(list.first.id, 'txn_1');
    });

    test('updateHandoverDetails sends patch and updates details', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          '_id': 'txn_handover',
          'lotId': 'lot_1',
          'collectorId': 'col_1',
          'recyclerId': 'rec_1',
          'amount': 1000,
          'handoverDetails': {'receivedBy': 'Ramesh', 'verifiedBy': 'Suresh'},
        },
      };

      final updated = await dataSource.updateHandoverDetails(
        transactionId: 'txn_handover',
        receivedBy: 'Ramesh',
        verifiedBy: 'Suresh',
        latitude: 28.5,
        longitude: 77.2,
      );

      expect(mockApiClient.capturedPath, '/transactions/txn_handover/handover');
      expect(mockApiClient.capturedData['receivedBy'], 'Ramesh');
      expect(mockApiClient.capturedData['verifiedBy'], 'Suresh');
      expect(mockApiClient.capturedData['handoverGPS']['latitude'], 28.5);
      expect(updated.handoverDetails.receivedBy, 'Ramesh');
    });

    test('updatePaymentStatus sends patch and updates status', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          '_id': 'txn_pay',
          'lotId': 'lot_1',
          'collectorId': 'col_1',
          'recyclerId': 'rec_1',
          'amount': 1000,
          'paymentStatus': 'completed',
          'paymentDetails': {'transactionId': 'UPI_123'},
        },
      };

      final updated = await dataSource.updatePaymentStatus(
        transactionId: 'txn_pay',
        paymentStatus: 'completed',
        paymentTransactionId: 'UPI_123',
      );

      expect(mockApiClient.capturedPath, '/transactions/txn_pay/payment');
      expect(mockApiClient.capturedData['paymentStatus'], 'completed');
      expect(mockApiClient.capturedData['transactionId'], 'UPI_123');
      expect(updated.paymentStatus, PaymentStatus.completed);
    });
  });

  group('Domain Use Cases & Repository Tests', () {
    late TransactionsRepository repository;
    late MockApiClient mockApiClient;
    late TransactionsRemoteDataSource dataSource;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = TransactionsRemoteDataSourceImpl(apiClient: mockApiClient);
      repository = TransactionsRepositoryImpl(remoteDataSource: dataSource);
    });

    test('CreateTransactionUseCase and GetTransactionByIdUseCase delegate properly', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          '_id': 'txn_usecase',
          'lotId': 'lot_9',
          'collectorId': 'col_9',
          'recyclerId': 'rec_9',
          'amount': 3000,
        },
      };

      final createUseCase = CreateTransactionUseCase(repository);
      final created = await createUseCase(
        lotId: 'lot_9',
        paymentMethod: 'upi',
        amount: 3000,
      );
      expect(created.id, 'txn_usecase');

      final getUseCase = GetTransactionByIdUseCase(repository);
      final fetched = await getUseCase('txn_usecase');
      expect(fetched.id, 'txn_usecase');
    });

    test('Handover and Payment use cases delegate properly', () async {
      mockApiClient.responseData = {
        'success': true,
        'data': {
          '_id': 'txn_ops',
          'lotId': 'lot_ops',
          'collectorId': 'col_ops',
          'recyclerId': 'rec_ops',
          'amount': 500,
          'paymentStatus': 'completed',
        },
      };

      final handoverUseCase = UpdateHandoverDetailsUseCase(repository);
      final afterHandover = await handoverUseCase(
        transactionId: 'txn_ops',
        receivedBy: 'Test Receiver',
      );
      expect(afterHandover.id, 'txn_ops');

      final paymentUseCase = UpdatePaymentStatusUseCase(repository);
      final afterPayment = await paymentUseCase(
        transactionId: 'txn_ops',
        paymentStatus: 'completed',
      );
      expect(afterPayment.paymentStatus, PaymentStatus.completed);
    });

    test(
      'Collector and Recycler transactions list use cases delegate properly',
      () async {
        mockApiClient.responseData = {
          'success': true,
          'data': {
            'transactions': [
              {
                '_id': 'txn_list_1',
                'lotId': 'lot_1',
                'collectorId': 'col_1',
                'recyclerId': 'rec_1',
                'amount': 500,
              },
            ],
          },
        };

        final colUseCase = GetCollectorTransactionsUseCase(repository);
        final colList = await colUseCase();
        expect(colList.length, 1);

        final recUseCase = GetRecyclerTransactionsUseCase(repository);
        final recList = await recUseCase();
        expect(recList.length, 1);
      },
    );
  });
}
