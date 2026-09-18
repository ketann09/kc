import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/create_transaction_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_handover_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_payment_status_usecase.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/screens/transaction_details_screen.dart';

class MockTransactionsRepo implements TransactionsRepository {
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
    return transaction!;
  }

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) async {
    return transaction!;
  }

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async =>
      [];

  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async =>
      [];

  @override
  Future<TransactionEntity> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) async {
    return transaction!;
  }

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async {
    return transaction!;
  }
}

void main() {
  late MockTransactionsRepo repo;
  late TransactionDetailsBloc bloc;

  setUp(() {
    repo = MockTransactionsRepo();
    bloc = TransactionDetailsBloc(
      getTransactionByIdUseCase: GetTransactionByIdUseCase(repo),
      createTransactionUseCase: CreateTransactionUseCase(repo),
      updateHandoverDetailsUseCase: UpdateHandoverDetailsUseCase(repo),
      updatePaymentStatusUseCase: UpdatePaymentStatusUseCase(repo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildTestWidget({
    required TransactionEntity initialTransaction,
    bool isRecycler = true,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: TransactionDetailsScreen(
        initialTransaction: initialTransaction,
        isRecycler: isRecycler,
        bloc: bloc,
      ),
    );
  }

  testWidgets('renders loaded transaction details correctly', (tester) async {
    const txn = TransactionEntity(
      id: 'txn_12345678',
      lotId: 'lot_999',
      collectorId: 'col_1',
      collectorName: 'राजेश कुमार',
      recyclerId: 'rec_1',
      recyclerName: 'स्वच्छ रीसाइक्लिंग',
      amount: 4000.0,
      paymentMethod: PaymentMethod.upi,
      paymentStatus: PaymentStatus.pending,
      status: TransactionStatus.inProgress,
      commission: TransactionCommissionEntity(
        platformFee: 200.0,
        commissionRate: 5.0,
        netAmount: 3800.0,
      ),
      weightDetails: TransactionWeightDetailsEntity(
        actualWeight: 80.0,
        estimatedWeight: 75.0,
        weightDifference: 5.0,
      ),
    );

    await tester.pumpWidget(buildTestWidget(initialTransaction: txn));
    await tester.pumpAndSettle();

    // Check header
    expect(find.text('लेन-देन विवरण'), findsOneWidget);
    expect(find.text('प्रगति में'), findsOneWidget);

    // Check party names
    expect(find.text('राजेश कुमार'), findsOneWidget);
    expect(find.text('स्वच्छ रीसाइक्लिंग'), findsOneWidget);

    // Check amounts
    expect(find.text('₹4000'), findsOneWidget);
    expect(find.text('- ₹200'), findsOneWidget);
    expect(find.text('₹3800'), findsOneWidget);

    // Check weights
    expect(find.text('80.0 kg'), findsOneWidget);
    expect(find.text('75.0 kg'), findsOneWidget);
  });

  testWidgets('shows payment button for recycler and opens payment modal',
      (tester) async {
    const txn = TransactionEntity(
      id: 'txn_rec_test',
      lotId: 'lot_rec',
      collectorId: 'col_1',
      recyclerId: 'rec_1',
      amount: 2000.0,
      paymentStatus: PaymentStatus.pending,
    );

    await tester.pumpWidget(buildTestWidget(
      initialTransaction: txn,
      isRecycler: true,
    ));
    await tester.pumpAndSettle();

    final payButton = find.widgetWithText(ElevatedButton, 'भुगतान दर्ज करें');
    expect(payButton, findsOneWidget);

    await tester.ensureVisible(payButton);
    await tester.tap(payButton);
    await tester.pumpAndSettle();

    expect(find.text('भुगतान स्थिति अपडेट करें'), findsOneWidget);
    expect(find.text('पुष्टि करें एवं सहेजें'), findsOneWidget);
  });

  testWidgets('hides payment button for collector and shows waiting notice',
      (tester) async {
    const txn = TransactionEntity(
      id: 'txn_col_test',
      lotId: 'lot_col',
      collectorId: 'col_1',
      recyclerId: 'rec_1',
      amount: 2000.0,
      paymentStatus: PaymentStatus.pending,
    );

    await tester.pumpWidget(buildTestWidget(
      initialTransaction: txn,
      isRecycler: false, // Collector view
    ));
    await tester.pumpAndSettle();

    final payButton = find.widgetWithText(ElevatedButton, 'भुगतान दर्ज करें');
    expect(payButton, findsNothing);

    expect(
      find.text(
          'भुगतान केवल रीसाइक्लर द्वारा दर्ज किया जा सकता है। कृपया प्रतीक्षा करें।'),
      findsOneWidget,
    );
  });

  testWidgets('shows completed ledger badge when payment is completed',
      (tester) async {
    const txn = TransactionEntity(
      id: 'txn_complete_test',
      lotId: 'lot_complete',
      collectorId: 'col_1',
      recyclerId: 'rec_1',
      amount: 2000.0,
      paymentStatus: PaymentStatus.completed,
      status: TransactionStatus.completed,
    );

    await tester.pumpWidget(buildTestWidget(
      initialTransaction: txn,
      isRecycler: true,
    ));
    await tester.pumpAndSettle();

    expect(
      find.text('भुगतान सफल! लेज़र (Ledger) में प्रविष्टियां दर्ज हो चुकी हैं।'),
      findsOneWidget,
    );
  });
}
