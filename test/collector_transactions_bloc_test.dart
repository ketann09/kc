import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_state.dart';

class MockTransactionsRepository implements TransactionsRepository {
  bool shouldThrow = false;
  String errorMessage = 'त्रुटि हुई';
  List<TransactionEntity> collectorTransactions = [];

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldThrow) {
      throw ApiException.unknown(message: errorMessage);
    }
    return collectorTransactions;
  }

  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return [];
  }

  @override
  Future<TransactionEntity> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockTransactionsRepository repository;
  late CollectorTransactionsBloc bloc;

  final samplePaidTxn = TransactionEntity(
    id: 'txn_paid_1',
    lotId: 'lot_101',
    collectorId: 'col_1',
    recyclerId: 'rec_1',
    amount: 10000.0,
    paymentStatus: PaymentStatus.completed,
    status: TransactionStatus.completed,
    commission: const TransactionCommissionEntity(
      platformFee: 500.0,
      commissionRate: 5.0,
      netAmount: 9500.0,
    ),
  );

  final samplePendingTxn = TransactionEntity(
    id: 'txn_pending_1',
    lotId: 'lot_102',
    collectorId: 'col_1',
    recyclerId: 'rec_1',
    amount: 3000.0,
    paymentStatus: PaymentStatus.pending,
    status: TransactionStatus.inProgress,
    commission: const TransactionCommissionEntity(
      platformFee: 150.0,
      commissionRate: 5.0,
      netAmount: 2850.0,
    ),
  );

  setUp(() {
    repository = MockTransactionsRepository();
    bloc = CollectorTransactionsBloc(
      getCollectorTransactionsUseCase: GetCollectorTransactionsUseCase(
        repository,
      ),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is CollectorTransactionsInitial', () {
    expect(bloc.state, const CollectorTransactionsInitial());
  });

  test('emits [Loading, Loaded] and computes earnings correctly from backend state', () async {
    repository.collectorTransactions = [samplePaidTxn, samplePendingTxn];

    final expectedStates = [
      const CollectorTransactionsLoading(),
      isA<CollectorTransactionsLoaded>()
          .having((s) => s.transactions.length, 'length', 2)
          .having((s) => s.totalEarnings, 'totalEarnings', 9500.0)
          .having((s) => s.pendingEarnings, 'pendingEarnings', 2850.0)
          .having((s) => s.completedCount, 'completedCount', 1),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchCollectorTransactionsEvent());
  });

  test('handles empty transaction history returning zero earnings', () async {
    repository.collectorTransactions = [];

    final expectedStates = [
      const CollectorTransactionsLoading(),
      isA<CollectorTransactionsLoaded>()
          .having((s) => s.transactions.isEmpty, 'isEmpty', true)
          .having((s) => s.totalEarnings, 'totalEarnings', 0.0)
          .having((s) => s.pendingEarnings, 'pendingEarnings', 0.0)
          .having((s) => s.completedCount, 'completedCount', 0),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchCollectorTransactionsEvent());
  });

  test('emits [Loading, Failure] on API failure', () async {
    repository.shouldThrow = true;
    repository.errorMessage = 'सर्वर त्रुटि';

    final expectedStates = [
      const CollectorTransactionsLoading(),
      isA<CollectorTransactionsFailure>().having(
        (s) => s.message,
        'message',
        'सर्वर त्रुटि',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchCollectorTransactionsEvent());
  });

  test(
    'filters transactions by status correctly without altering total earnings',
    () async {
      repository.collectorTransactions = [samplePaidTxn, samplePendingTxn];

      bloc.add(const FetchCollectorTransactionsEvent());
      await pumpEventQueue();

      expect(bloc.state, isA<CollectorTransactionsLoaded>());

      // Filter to completed only
      bloc.add(const FilterCollectorTransactionsEvent('completed'));
      await pumpEventQueue();

      final completedState = bloc.state as CollectorTransactionsLoaded;
      expect(completedState.transactions.length, 1);
      expect(completedState.transactions.first.id, 'txn_paid_1');
      expect(completedState.totalEarnings, 9500.0);
      expect(completedState.pendingEarnings, 2850.0);

      // Filter to pending only
      bloc.add(const FilterCollectorTransactionsEvent('pending'));
      await pumpEventQueue();

      final pendingState = bloc.state as CollectorTransactionsLoaded;
      expect(pendingState.transactions.length, 1);
      expect(pendingState.transactions.first.id, 'txn_pending_1');

      // Filter to all
      bloc.add(const FilterCollectorTransactionsEvent('all'));
      await pumpEventQueue();

      final allState = bloc.state as CollectorTransactionsLoaded;
      expect(allState.transactions.length, 2);
    },
  );
}
