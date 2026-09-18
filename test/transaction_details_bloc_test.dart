import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/create_transaction_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_handover_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_payment_status_usecase.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/bloc/transaction_details_event.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/bloc/transaction_details_state.dart';

class MockTransactionsRepository implements TransactionsRepository {
  bool shouldThrow = false;
  String errorMessage = 'त्रुटि हुई';
  TransactionEntity? transaction;

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) async {
    if (shouldThrow) throw ApiException.unknown(message: errorMessage);
    return transaction ??
        TransactionEntity(
          id: 'txn_created',
          lotId: lotId,
          collectorId: 'col_1',
          recyclerId: 'rec_1',
          amount: amount,
        );
  }

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) async {
    if (shouldThrow) throw ApiException.unknown(message: errorMessage);
    return transaction ??
        TransactionEntity(
          id: transactionId,
          lotId: 'lot_1',
          collectorId: 'col_1',
          recyclerId: 'rec_1',
          amount: 1000,
        );
  }

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return [];
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
    if (shouldThrow) throw ApiException.unknown(message: errorMessage);
    final base = transaction ??
        TransactionEntity(
          id: transactionId,
          lotId: 'lot_1',
          collectorId: 'col_1',
          recyclerId: 'rec_1',
          amount: 1000,
        );
    return base.copyWith(
      handoverDetails: TransactionHandoverDetailsEntity(
        receivedBy: receivedBy,
        verifiedBy: verifiedBy,
        handoverTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async {
    if (shouldThrow) throw ApiException.unknown(message: errorMessage);
    final base = transaction ??
        TransactionEntity(
          id: transactionId,
          lotId: 'lot_1',
          collectorId: 'col_1',
          recyclerId: 'rec_1',
          amount: 1000,
        );
    return base.copyWith(
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      status: paymentStatus == 'completed'
          ? TransactionStatus.completed
          : base.status,
      completedAt: paymentStatus == 'completed' ? DateTime.now() : null,
    );
  }
}

void main() {
  late MockTransactionsRepository repository;
  late TransactionDetailsBloc bloc;

  setUp(() {
    repository = MockTransactionsRepository();
    bloc = TransactionDetailsBloc(
      getTransactionByIdUseCase: GetTransactionByIdUseCase(repository),
      createTransactionUseCase: CreateTransactionUseCase(repository),
      updateHandoverDetailsUseCase: UpdateHandoverDetailsUseCase(repository),
      updatePaymentStatusUseCase: UpdatePaymentStatusUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is TransactionDetailsInitial', () {
    expect(bloc.state, const TransactionDetailsInitial());
  });

  test('emits [Loading, Loaded] on FetchTransactionDetailsEvent success', () async {
    final expectedStates = [
      const TransactionDetailsLoading(),
      isA<TransactionDetailsLoaded>()
          .having((s) => s.transaction.id, 'id', 'txn_test'),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchTransactionDetailsEvent('txn_test'));
  });

  test('emits [Loading, Failure] on FetchTransactionDetailsEvent failure', () async {
    repository.shouldThrow = true;
    repository.errorMessage = 'लेन-देन नहीं मिला';

    final expectedStates = [
      const TransactionDetailsLoading(),
      isA<TransactionDetailsFailure>()
          .having((s) => s.message, 'message', 'लेन-देन नहीं मिला'),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchTransactionDetailsEvent('txn_bad'));
  });

  test('emits [Loading, Loaded with actionSuccessMessage] on CreateTransactionEvent', () async {
    final expectedStates = [
      const TransactionDetailsLoading(),
      isA<TransactionDetailsLoaded>().having(
        (s) => s.actionSuccessMessage,
        'actionSuccessMessage',
        'लेन-देन सफलतापूर्वक बनाया गया',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const CreateTransactionEvent(
      lotId: 'lot_1',
      paymentMethod: 'cash',
      amount: 1200,
    ));
  });

  test('emits handover loading and updated state on UpdateHandoverEvent', () async {
    // Seed state as loaded
    // ignore: invalid_use_of_visible_for_testing_member
    bloc.emit(const TransactionDetailsLoaded(
      TransactionEntity(
        id: 'txn_h',
        lotId: 'lot_1',
        collectorId: 'col_1',
        recyclerId: 'rec_1',
        amount: 1000,
      ),
    ));

    final expectedStates = [
      isA<TransactionDetailsLoaded>().having(
        (s) => s.isSubmittingHandover,
        'isSubmittingHandover',
        true,
      ),
      isA<TransactionDetailsLoaded>()
          .having((s) => s.isSubmittingHandover, 'isSubmittingHandover', false)
          .having((s) => s.actionSuccessMessage, 'actionSuccessMessage',
              'हैंडओवर विवरण सफलतापूर्वक सहेजा गया')
          .having((s) => s.transaction.handoverDetails.receivedBy, 'receivedBy',
              'Ramesh'),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const UpdateHandoverEvent(
      transactionId: 'txn_h',
      receivedBy: 'Ramesh',
    ));
  });

  test('emits payment loading and updated state on UpdatePaymentEvent', () async {
    // Seed state as loaded
    // ignore: invalid_use_of_visible_for_testing_member
    bloc.emit(const TransactionDetailsLoaded(
      TransactionEntity(
        id: 'txn_p',
        lotId: 'lot_1',
        collectorId: 'col_1',
        recyclerId: 'rec_1',
        amount: 1000,
      ),
    ));

    final expectedStates = [
      isA<TransactionDetailsLoaded>().having(
        (s) => s.isSubmittingPayment,
        'isSubmittingPayment',
        true,
      ),
      isA<TransactionDetailsLoaded>()
          .having((s) => s.isSubmittingPayment, 'isSubmittingPayment', false)
          .having((s) => s.actionSuccessMessage, 'actionSuccessMessage',
              'भुगतान स्थिति सफलतापूर्वक अपडेट की गई')
          .having((s) => s.transaction.paymentStatus, 'paymentStatus',
              PaymentStatus.completed),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const UpdatePaymentEvent(
      transactionId: 'txn_p',
      paymentStatus: 'completed',
    ));
  });

  test('ResetTransactionActionEvent clears action messages', () async {
    // Seed with messages
    // ignore: invalid_use_of_visible_for_testing_member
    bloc.emit(const TransactionDetailsLoaded(
      TransactionEntity(
        id: 'txn_r',
        lotId: 'lot_1',
        collectorId: 'col_1',
        recyclerId: 'rec_1',
        amount: 1000,
      ),
      actionSuccessMessage: 'सफल',
      actionErrorMessage: 'त्रुटि',
    ));

    expect(
      (bloc.state as TransactionDetailsLoaded).actionSuccessMessage,
      'सफल',
    );

    bloc.add(const ResetTransactionActionEvent());
    await pumpEventQueue();

    expect(
      (bloc.state as TransactionDetailsLoaded).actionSuccessMessage,
      isNull,
    );
    expect(
      (bloc.state as TransactionDetailsLoaded).actionErrorMessage,
      isNull,
    );
  });
}
