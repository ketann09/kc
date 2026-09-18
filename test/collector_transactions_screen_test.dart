import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_state.dart';
import 'package:kabadiwala_connect/features/collector/presentation/screens/collector_transactions_screen.dart';

class MockTransactionsRepo implements TransactionsRepository {
  List<TransactionEntity> transactions = [];
  bool shouldFail = false;

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) =>
      throw UnimplementedError();

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldFail) throw Exception('सर्वर त्रुटि');
    return transactions;
  }

  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) => throw UnimplementedError();
}

void main() {
  late MockTransactionsRepo repo;
  late CollectorTransactionsBloc bloc;

  final samplePaidTxn = TransactionEntity(
    id: 'txn_c_1',
    lotId: 'lot_c_1',
    collectorId: 'col_1',
    recyclerId: 'rec_1',
    recyclerName: 'ग्रीन रीसाइक्लिंग',
    amount: 10000.0,
    paymentStatus: PaymentStatus.completed,
    status: TransactionStatus.completed,
    commission: const TransactionCommissionEntity(
      platformFee: 500.0,
      netAmount: 9500.0,
    ),
    notes: 'ई-कचरा लॉट',
  );

  final samplePendingTxn = TransactionEntity(
    id: 'txn_c_2',
    lotId: 'lot_c_2',
    collectorId: 'col_1',
    recyclerId: 'rec_1',
    amount: 3000.0,
    paymentStatus: PaymentStatus.pending,
    status: TransactionStatus.inProgress,
    commission: const TransactionCommissionEntity(
      platformFee: 150.0,
      netAmount: 2850.0,
    ),
  );

  setUp(() {
    repo = MockTransactionsRepo();
    bloc = CollectorTransactionsBloc(
      getCollectorTransactionsUseCase: GetCollectorTransactionsUseCase(repo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CollectorTransactionsScreen(bloc: bloc),
    );
  }

  testWidgets('renders earnings summary tiles and transaction cards', (
    tester,
  ) async {
    bloc.emit(
      CollectorTransactionsLoaded(
        transactions: [samplePaidTxn, samplePendingTxn],
        totalEarnings: 9500.0,
        pendingEarnings: 2850.0,
        completedCount: 1,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Check earnings summary values
    expect(find.text('₹9500'), findsNWidgets(2)); // in earnings tile & in card
    expect(find.text('कुल कमाई'), findsOneWidget);
    expect(find.text('₹2850'), findsNWidgets(2)); // in earnings tile & in card
    expect(find.text('भुगतान बाकी'), findsWidgets);

    // Check transaction cards
    expect(find.text('ई-कचरा लॉट'), findsOneWidget);
    // 'भुगतान पूरा' appears in filter chip and status badge
    expect(find.text('भुगतान पूरा'), findsNWidgets(2));
  });

  testWidgets('renders empty state when transaction list is empty', (
    tester,
  ) async {
    bloc.emit(
      const CollectorTransactionsLoaded(
        transactions: [],
        totalEarnings: 0.0,
        pendingEarnings: 0.0,
        completedCount: 0,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('कोई लेन-देन नहीं मिला'), findsOneWidget);
  });

  testWidgets('renders failure state on error', (tester) async {
    bloc.emit(
      const CollectorTransactionsFailure('सर्वर से संपर्क नहीं हो सका'),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('लोड करने में समस्या हुई'), findsOneWidget);
    expect(find.text('सर्वर से संपर्क नहीं हो सका'), findsOneWidget);
    expect(find.text('पुनः प्रयास करें'), findsOneWidget);
  });

  testWidgets(
    'tapping transaction card navigates to TransactionDetailsScreen in collector mode',
    (tester) async {
      bloc.emit(
        CollectorTransactionsLoaded(
          transactions: [samplePaidTxn],
          totalEarnings: 9500.0,
          pendingEarnings: 0.0,
          completedCount: 1,
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('ई-कचरा लॉट'));
      await tester.pumpAndSettle();

      // Navigated to details screen
      expect(find.text('लेन-देन विवरण'), findsOneWidget);
      // Collector cannot trigger payment
      expect(
        find.widgetWithText(ElevatedButton, 'भुगतान दर्ज करें'),
        findsNothing,
      );
    },
  );
}
