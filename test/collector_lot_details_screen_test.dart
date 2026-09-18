import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/collector_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_lot_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'package:kabadiwala_connect/features/collector/presentation/screens/collector_lot_details_screen.dart';

class MockLotsRepo implements CollectorLotsRepository {
  LotEntity? lot;

  @override
  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async => [];

  @override
  Future<LotEntity> getLotById(String lotId) async => lot!;

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) =>
      throw UnimplementedError();

  @override
  Future<LotEntity> createLot(CreateLotParams params) =>
      throw UnimplementedError();
}

class MockTxnRepo implements TransactionsRepository {
  List<TransactionEntity> transactions = [];

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
  }) async => transactions;

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
  late MockLotsRepo lotsRepo;
  late MockTxnRepo txnRepo;

  final sampleCompletedLot = LotEntity(
    id: 'lot_comp_1',
    collectorId: 'col_1',
    recyclerId: 'rec_1',
    materialName: 'प्लास्टिक',
    estimatedWeight: 50.0,
    actualWeight: 52.0,
    estimatedPrice: 1000.0,
    finalPrice: 1040.0,
    status: LotStatus.completed,
    images: const ['https://example.com/lot.jpg'],
    createdAt: DateTime(2026, 9, 18),
  );

  setUp(() {
    lotsRepo = MockLotsRepo();
    txnRepo = MockTxnRepo();
    lotsRepo.lot = sampleCompletedLot;
  });

  Widget buildTestWidget({LotEntity? initialLot}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      routes: {
        '/collector-transactions': (_) =>
            const Scaffold(body: Text('Collector Transactions Route')),
      },
      home: CollectorLotDetailsScreen(
        lotId: 'lot_comp_1',
        initialLot: initialLot,
        getLotDetailsUseCase: GetLotDetailsUseCase(lotsRepo),
        getCollectorTransactionsUseCase: GetCollectorTransactionsUseCase(
          txnRepo,
        ),
      ),
    );
  }

  testWidgets('renders completed lot details with "लेन-देन देखें" CTA', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(initialLot: sampleCompletedLot));
    await tester.pumpAndSettle();

    expect(find.text('लॉट विवरण'), findsOneWidget);
    expect(find.text('पूरा हुआ'), findsOneWidget);
    expect(find.text('यह लॉट सफलतापूर्वक पूरा हो चुका है'), findsOneWidget);
    expect(find.text('लेन-देन देखें'), findsOneWidget);
  });

  testWidgets(
    'tapping "लेन-देन देखें" navigates to transaction details when matching transaction exists',
    (tester) async {
      txnRepo.transactions = [
        TransactionEntity(
          id: 'txn_found_1',
          lotId: 'lot_comp_1',
          collectorId: 'col_1',
          recyclerId: 'rec_1',
          amount: 1040.0,
          paymentStatus: PaymentStatus.completed,
        ),
      ];

      await tester.pumpWidget(buildTestWidget(initialLot: sampleCompletedLot));
      await tester.pumpAndSettle();

      final cta = find.text('लेन-देन देखें');
      expect(cta, findsOneWidget);

      await tester.tap(cta);
      await tester.pumpAndSettle();

      // Verify it navigated to TransactionDetailsScreen
      expect(find.text('लेन-देन विवरण'), findsOneWidget);
      // Collector cannot trigger payment
      expect(
        find.widgetWithText(ElevatedButton, 'भुगतान दर्ज करें'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'tapping "लेन-देन देखें" shows informational dialog when no transaction exists yet',
    (tester) async {
      txnRepo.transactions = []; // No transaction created yet by recycler

      await tester.pumpWidget(buildTestWidget(initialLot: sampleCompletedLot));
      await tester.pumpAndSettle();

      final cta = find.text('लेन-देन देखें');
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('लेन-देन की स्थिति'), findsOneWidget);
      expect(
        find.text(
          'इस लॉट के लिए रीसाइक्लर द्वारा अभी लेन-देन नहीं बनाया गया है। जैसे ही रीसाइक्लर लेन-देन दर्ज करेगा, यह आपकी लेन-देन सूची में दिखेगा।',
        ),
        findsOneWidget,
      );
      expect(find.text('सभी लेन-देन देखें'), findsOneWidget);

      // Tapping "सभी लेन-देन देखें" navigates to collector transactions route
      await tester.tap(find.text('सभी लेन-देन देखें'));
      await tester.pumpAndSettle();

      expect(find.text('Collector Transactions Route'), findsOneWidget);
    },
  );
}
