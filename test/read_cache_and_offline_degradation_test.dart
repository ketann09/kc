import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kabadiwala_connect/core/localization/app_language.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/storage/read_cache_storage.dart';
import 'package:kabadiwala_connect/core/widgets/offline_stale_banner.dart';
import 'package:kabadiwala_connect/data/models/lot_model.dart';
import 'package:kabadiwala_connect/data/models/transaction_model.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/entities/material_entity.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/collector_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/materials_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_collector_lots_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_live_scrap_rates_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_lot_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_state.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_transactions/collector_transactions_state.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_event.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_state.dart';

// ==========================================
// TEST DOUBLES & REPOSITORIES
// ==========================================

class FakeCollectorLotsRepository implements CollectorLotsRepository {
  bool shouldThrow = false;
  ApiException? exceptionToThrow;
  List<LotEntity> lots = [];

  @override
  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldThrow) {
      throw exceptionToThrow ?? ApiException.network();
    }
    return lots;
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    if (shouldThrow) {
      throw exceptionToThrow ?? ApiException.network();
    }
    return lots.firstWhere((l) => l.id == lotId);
  }

  @override
  Future<LotEntity> createLot(CreateLotParams params) async {
    throw UnimplementedError();
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async {
    throw UnimplementedError();
  }
}

class FakeMaterialsRepository implements MaterialsRepository {
  bool shouldThrow = false;
  ApiException? exceptionToThrow;
  List<MaterialEntity> materials = [];

  @override
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) async {
    if (shouldThrow) {
      throw exceptionToThrow ?? ApiException.network();
    }
    return materials;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return [];
  }

  @override
  Future<MaterialEntity> getMaterialById(String materialId) async {
    throw UnimplementedError();
  }
}

class FakeRecyclerLotsRepository implements RecyclerLotsRepository {
  bool shouldThrow = false;
  ApiException? exceptionToThrow;
  List<LotEntity> lots = [];

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldThrow) {
      throw exceptionToThrow ?? ApiException.network();
    }
    return lots;
  }

  @override
  Future<LotEntity> getLotById(String lotId) async => throw UnimplementedError();
  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async => throw UnimplementedError();
  @override
  Future<LotEntity> updateLotLifecycle({required String lotId, required String status, double? actualWeight, double? finalPrice}) async => throw UnimplementedError();
}

class FakeTransactionsRepository implements TransactionsRepository {
  bool shouldThrow = false;
  ApiException? exceptionToThrow;
  List<TransactionEntity> transactions = [];

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldThrow) {
      throw exceptionToThrow ?? ApiException.network();
    }
    return transactions;
  }

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) async => throw UnimplementedError();
  @override
  Future<TransactionEntity> getTransactionById(String transactionId) async => throw UnimplementedError();
  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({int page = 1, int limit = 10, String? status}) async => throw UnimplementedError();
  @override
  Future<TransactionEntity> updateHandoverDetails({required String transactionId, List<String>? handoverPhotos, double? latitude, double? longitude, String? receivedBy, String? verifiedBy}) async => throw UnimplementedError();
  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleLot = LotEntity(
    id: 'lot_001',
    collectorId: 'collector_001',
    materialId: 'mat_plastic',
    materialName: 'Plastic PET',
    estimatedWeight: 25.0,
    estimatedPrice: 350.0,
    status: LotStatus.pending,
    createdAt: DateTime(2026, 9, 15, 10, 30),
  );

  final sampleMaterial = const MaterialEntity(
    id: 'mat_plastic',
    name: 'Plastic PET',
    category: 'Plastic',
  );

  final sampleTransaction = TransactionEntity(
    id: 'txn_001',
    lotId: 'lot_001',
    collectorId: 'collector_001',
    recyclerId: 'recycler_001',
    amount: 350.0,
    paymentMethod: PaymentMethod.cash,
    paymentStatus: PaymentStatus.completed,
    status: TransactionStatus.completed,
    createdAt: DateTime(2026, 9, 15, 11, 0),
  );

  group('ReadCacheStorage Infrastructure Tests', () {
    late SharedPreferences prefs;
    late SharedPreferencesReadCacheStorage cacheStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cacheStorage = SharedPreferencesReadCacheStorage(prefs: prefs);
    });

    test('Saves and gets domain item preserving timestamp', () async {
      final now = DateTime.now();
      final lotModel = LotModel.fromEntity(sampleLot);
      await cacheStorage.save<LotModel>(
        key: 'cached_lot',
        data: lotModel,
        toJson: (m) => m.toJson(),
      );

      final entry = await cacheStorage.get<LotModel>(
        key: 'cached_lot',
        fromJson: (json) => LotModel.fromJson(json),
      );

      expect(entry, isNotNull);
      expect(entry!.data.id, equals('lot_001'));
      expect(entry.data.materialName, equals('Plastic PET'));
      expect(entry.data.estimatedWeight, equals(25.0));
      expect(entry.data.status, equals(LotStatus.pending));
      expect(entry.cachedAt.difference(now).inSeconds.abs(), lessThan(5));
    });

    test('Saves and gets domain item list preserving timestamp', () async {
      final lotModel = LotModel.fromEntity(sampleLot);
      await cacheStorage.saveList<LotModel>(
        key: 'cached_lots',
        data: [lotModel],
        toJson: (m) => m.toJson(),
      );

      final entry = await cacheStorage.getList<LotModel>(
        key: 'cached_lots',
        fromJson: (json) => LotModel.fromJson(json),
      );

      expect(entry, isNotNull);
      expect(entry!.data.length, equals(1));
      expect(entry.data.first.id, equals('lot_001'));
    });

    test('Returns null on cache miss', () async {
      final entry = await cacheStorage.get<LotModel>(
        key: 'nonexistent_key',
        fromJson: (json) => LotModel.fromJson(json),
      );
      expect(entry, isNull);
    });

    test('Corrupted JSON does not throw and returns null safely', () async {
      await prefs.setString('read_cache_corrupt_key', '{not_a_valid_json: 123');

      final entry = await cacheStorage.get<LotModel>(
        key: 'corrupt_key',
        fromJson: (json) => LotModel.fromJson(json),
      );
      expect(entry, isNull);
    });

    test('isUsable accurately computes age against TTL', () {
      final past = DateTime.now().subtract(const Duration(hours: 2));
      final entry = ReadCacheEntry<String>(data: 'stale', cachedAt: past);

      expect(entry.isUsable(maxAge: const Duration(hours: 1)), isFalse);
      expect(entry.isUsable(maxAge: const Duration(hours: 3)), isTrue);
    });

    test('Remove and clear cache', () async {
      final lotModel = LotModel.fromEntity(sampleLot);
      await cacheStorage.save<LotModel>(
        key: 'key1',
        data: lotModel,
        toJson: (m) => m.toJson(),
      );
      await cacheStorage.save<LotModel>(
        key: 'key2',
        data: lotModel,
        toJson: (m) => m.toJson(),
      );

      await cacheStorage.remove('key1');
      expect(
        await cacheStorage.get<LotModel>(key: 'key1', fromJson: (j) => LotModel.fromJson(j)),
        isNull,
      );
      expect(
        await cacheStorage.get<LotModel>(key: 'key2', fromJson: (j) => LotModel.fromJson(j)),
        isNotNull,
      );

      await cacheStorage.clear();
      expect(
        await cacheStorage.get<LotModel>(key: 'key2', fromJson: (j) => LotModel.fromJson(j)),
        isNull,
      );
    });
  });

  group('CollectorLotsBloc Read-Cache & Offline Degradation Tests', () {
    late FakeCollectorLotsRepository lotsRepo;
    late FakeMaterialsRepository materialsRepo;
    late SharedPreferences prefs;
    late SharedPreferencesReadCacheStorage cacheStorage;

    late GetCollectorLotsUseCase getCollectorLotsUseCase;
    late GetLotDetailsUseCase getLotDetailsUseCase;
    late GetLiveScrapRatesUseCase getLiveScrapRatesUseCase;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cacheStorage = SharedPreferencesReadCacheStorage(prefs: prefs);

      lotsRepo = FakeCollectorLotsRepository();
      materialsRepo = FakeMaterialsRepository();

      getCollectorLotsUseCase = GetCollectorLotsUseCase(lotsRepo);
      getLotDetailsUseCase = GetLotDetailsUseCase(lotsRepo);
      getLiveScrapRatesUseCase = GetLiveScrapRatesUseCase(materialsRepo);
    });

    CollectorLotsBloc buildBloc() {
      return CollectorLotsBloc(
        getCollectorLotsUseCase: getCollectorLotsUseCase,
        getLotDetailsUseCase: getLotDetailsUseCase,
        getLiveScrapRatesUseCase: getLiveScrapRatesUseCase,
        readCacheStorage: cacheStorage,
      );
    }

    test('A. Successful online fetch caches dashboard data and emits isOffline: false', () async {
      lotsRepo.lots = [sampleLot];
      materialsRepo.materials = [sampleMaterial];

      final bloc = buildBloc();
      bloc.add(const CollectorDashboardInitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorLotsLoading>(),
          predicate<CollectorDashboardLoaded>((state) {
            return state.recentLots.length == 1 &&
                state.recentLots.first.id == 'lot_001' &&
                state.isOffline == false &&
                state.isRefreshing == false;
          }),
        ]),
      );

      // Verify that cache was populated
      final cached = await cacheStorage.getList<LotEntity>(
        key: SharedPreferencesReadCacheStorage.collectorDashboardLotsKey,
        fromJson: (json) => LotModel.fromJson(json),
      );
      expect(cached, isNotNull);
      expect(cached!.data.length, equals(1));
      expect(cached.data.first.id, equals('lot_001'));

      await bloc.close();
    });

    test('B. Cold start offline with cache: emits cached data with isOffline: true', () async {
      // Pre-populate disk cache
      final lotModel = LotModel.fromEntity(sampleLot);
      await cacheStorage.saveList<LotEntity>(
        key: SharedPreferencesReadCacheStorage.collectorDashboardLotsKey,
        data: [lotModel],
        toJson: (m) => LotModel.fromEntity(m).toJson(),
      );

      // Repositories throw network error
      lotsRepo.shouldThrow = true;
      lotsRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const CollectorDashboardInitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorLotsLoading>(),
          predicate<CollectorDashboardLoaded>((state) {
            return state.recentLots.length == 1 &&
                state.recentLots.first.id == 'lot_001' &&
                state.isOffline == true &&
                state.cachedAt != null;
          }),
        ]),
      );

      await bloc.close();
    });

    test('C. Cold start offline WITHOUT cache: emits Failure with isOffline: true without fabricating data', () async {
      // Repositories throw network error and cache is empty
      lotsRepo.shouldThrow = true;
      lotsRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const CollectorDashboardInitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorLotsLoading>(),
          predicate<CollectorLotsFailure>((state) {
            return state.isOffline == true && state.message.isNotEmpty;
          }),
        ]),
      );

      await bloc.close();
    });

    test('D. Pull-to-refresh failure preserves loaded state and marks isOffline: true', () async {
      lotsRepo.lots = [sampleLot];
      materialsRepo.materials = [sampleMaterial];

      final bloc = buildBloc();

      // 1. Initial online load
      bloc.add(const CollectorDashboardInitRequested());
      await bloc.stream.firstWhere((s) => s is CollectorDashboardLoaded);

      // 2. Now network drops and user pulls to refresh
      lotsRepo.shouldThrow = true;
      lotsRepo.exceptionToThrow = ApiException.network();

      bloc.add(const CollectorDashboardInitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          // Indicates refreshing started
          predicate<CollectorDashboardLoaded>((s) => s.isRefreshing == true),
          // Refresh failed: data preserved, isOffline: true, isRefreshing: false, refreshError set
          predicate<CollectorDashboardLoaded>((s) =>
              s.recentLots.length == 1 &&
              s.isRefreshing == false &&
              s.isOffline == true &&
              s.refreshError != null),
        ]),
      );

      await bloc.close();
    });

    test('E. Pull-to-refresh reconnects and updates to authoritative backend data', () async {
      lotsRepo.lots = [sampleLot];
      materialsRepo.materials = [sampleMaterial];

      final bloc = buildBloc();

      // 1. Initial load
      bloc.add(const CollectorDashboardInitRequested());
      await bloc.stream.firstWhere((s) => s is CollectorDashboardLoaded);

      // 2. Refresh fails
      lotsRepo.shouldThrow = true;
      bloc.add(const CollectorDashboardInitRequested());
      await bloc.stream.firstWhere((s) => s is CollectorDashboardLoaded && s.isOffline == true);

      // 3. Network restores, new lot added
      lotsRepo.shouldThrow = false;
      final newLot = LotEntity(
        id: 'lot_002',
        collectorId: 'collector_001',
        materialId: 'mat_plastic',
        materialName: 'Plastic PET',
        estimatedWeight: 50.0,
        estimatedPrice: 700.0,
        status: LotStatus.pending,
        createdAt: DateTime(2026, 9, 15, 10, 30),
      );
      lotsRepo.lots = [sampleLot, newLot];

      bloc.add(const CollectorDashboardInitRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CollectorDashboardLoaded>((s) => s.isRefreshing == true),
          predicate<CollectorDashboardLoaded>((s) =>
              s.recentLots.length == 2 &&
              s.isRefreshing == false &&
              s.isOffline == false &&
              s.refreshError == null),
        ]),
      );

      await bloc.close();
    });
  });

  group('RecyclerDashboardBloc Read-Cache & Offline Degradation Tests', () {
    late FakeRecyclerLotsRepository recyclerRepo;
    late SharedPreferences prefs;
    late SharedPreferencesReadCacheStorage cacheStorage;
    late GetRecyclerLotsUseCase getRecyclerLotsUseCase;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cacheStorage = SharedPreferencesReadCacheStorage(prefs: prefs);

      recyclerRepo = FakeRecyclerLotsRepository();
      getRecyclerLotsUseCase = GetRecyclerLotsUseCase(recyclerRepo);
    });

    RecyclerDashboardBloc buildBloc() {
      return RecyclerDashboardBloc(
        getRecyclerLotsUseCase: getRecyclerLotsUseCase,
        readCacheStorage: cacheStorage,
      );
    }

    test('A. Successful online fetch caches incoming lots and emits isOffline: false', () async {
      recyclerRepo.lots = [sampleLot];

      final bloc = buildBloc();
      bloc.add(const FetchIncomingLots(refresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecyclerDashboardLoading>(),
          predicate<RecyclerDashboardLoaded>((state) =>
              state.lots.length == 1 &&
              state.isOffline == false &&
              state.isRefreshing == false),
        ]),
      );

      // Check cache storage
      final cached = await cacheStorage.getList<LotEntity>(
        key: SharedPreferencesReadCacheStorage.recyclerIncomingLotsKey,
        fromJson: (json) => LotModel.fromJson(json),
      );
      expect(cached, isNotNull);
      expect(cached!.data.length, equals(1));

      await bloc.close();
    });

    test('B. Cold start offline with cache emits cached data with isOffline: true', () async {
      final lotModel = LotModel.fromEntity(sampleLot);
      await cacheStorage.saveList<LotEntity>(
        key: SharedPreferencesReadCacheStorage.recyclerIncomingLotsKey,
        data: [lotModel],
        toJson: (m) => LotModel.fromEntity(m).toJson(),
      );

      recyclerRepo.shouldThrow = true;
      recyclerRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const FetchIncomingLots(refresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecyclerDashboardLoading>(),
          predicate<RecyclerDashboardLoaded>((state) =>
              state.lots.length == 1 &&
              state.isOffline == true &&
              state.cachedAt != null),
        ]),
      );

      await bloc.close();
    });

    test('C. Cold start offline without cache emits failure with isOffline: true', () async {
      recyclerRepo.shouldThrow = true;
      recyclerRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const FetchIncomingLots(refresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecyclerDashboardLoading>(),
          predicate<RecyclerDashboardFailure>((state) => state.isOffline == true),
        ]),
      );

      await bloc.close();
    });

    test('D. Refresh failure preserves loaded state and sets isOffline: true', () async {
      recyclerRepo.lots = [sampleLot];
      final bloc = buildBloc();

      bloc.add(const FetchIncomingLots());
      await bloc.stream.firstWhere((s) => s is RecyclerDashboardLoaded);

      // Network fails on refresh
      recyclerRepo.shouldThrow = true;
      recyclerRepo.exceptionToThrow = ApiException.network();

      bloc.add(const FetchIncomingLots(refresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RecyclerDashboardLoaded>((s) => s.isRefreshing == true),
          predicate<RecyclerDashboardLoaded>((s) =>
              stateLotsCount(s) == 1 &&
              s.isRefreshing == false &&
              s.isOffline == true &&
              s.refreshError != null),
        ]),
      );

      await bloc.close();
    });
  });

  group('CollectorTransactionsBloc Read-Cache & Offline Degradation Tests', () {
    late FakeTransactionsRepository transactionsRepo;
    late SharedPreferences prefs;
    late SharedPreferencesReadCacheStorage cacheStorage;
    late GetCollectorTransactionsUseCase getCollectorTransactionsUseCase;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cacheStorage = SharedPreferencesReadCacheStorage(prefs: prefs);

      transactionsRepo = FakeTransactionsRepository();
      getCollectorTransactionsUseCase = GetCollectorTransactionsUseCase(transactionsRepo);
    });

    CollectorTransactionsBloc buildBloc() {
      return CollectorTransactionsBloc(
        getCollectorTransactionsUseCase: getCollectorTransactionsUseCase,
        readCacheStorage: cacheStorage,
      );
    }

    test('A. Successful online fetch caches transactions and emits isOffline: false', () async {
      transactionsRepo.transactions = [sampleTransaction];

      final bloc = buildBloc();
      bloc.add(const FetchCollectorTransactionsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorTransactionsLoading>(),
          predicate<CollectorTransactionsLoaded>((state) =>
              state.transactions.length == 1 &&
              state.isOffline == false &&
              state.isRefreshing == false),
        ]),
      );

      final cached = await cacheStorage.getList<TransactionEntity>(
        key: SharedPreferencesReadCacheStorage.collectorTransactionsKey,
        fromJson: (json) => TransactionModel.fromJson(json),
      );
      expect(cached, isNotNull);
      expect(cached!.data.length, equals(1));

      await bloc.close();
    });

    test('B. Cold start offline with cache emits cached transactions with isOffline: true', () async {
      final txnModel = TransactionModel.fromEntity(sampleTransaction);
      await cacheStorage.saveList<TransactionEntity>(
        key: SharedPreferencesReadCacheStorage.collectorTransactionsKey,
        data: [txnModel],
        toJson: (m) => TransactionModel.fromEntity(m).toJson(),
      );

      transactionsRepo.shouldThrow = true;
      transactionsRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const FetchCollectorTransactionsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorTransactionsLoading>(),
          predicate<CollectorTransactionsLoaded>((state) =>
              state.transactions.length == 1 &&
              state.isOffline == true &&
              state.cachedAt != null),
        ]),
      );

      await bloc.close();
    });

    test('C. Cold start offline without cache emits failure with isOffline: true', () async {
      transactionsRepo.shouldThrow = true;
      transactionsRepo.exceptionToThrow = ApiException.network();

      final bloc = buildBloc();
      bloc.add(const FetchCollectorTransactionsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CollectorTransactionsLoading>(),
          predicate<CollectorTransactionsFailure>((state) => state.isOffline == true),
        ]),
      );

      await bloc.close();
    });

    test('D. Refresh failure preserves loaded transactions and sets isOffline: true', () async {
      transactionsRepo.transactions = [sampleTransaction];
      final bloc = buildBloc();

      bloc.add(const FetchCollectorTransactionsEvent());
      await bloc.stream.firstWhere((s) => s is CollectorTransactionsLoaded);

      transactionsRepo.shouldThrow = true;
      transactionsRepo.exceptionToThrow = ApiException.network();

      bloc.add(const FetchCollectorTransactionsEvent(refresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CollectorTransactionsLoaded>((s) => s.isRefreshing == true),
          predicate<CollectorTransactionsLoaded>((s) =>
              s.transactions.length == 1 &&
              s.isRefreshing == false &&
              s.isOffline == true &&
              s.refreshError != null),
        ]),
      );

      await bloc.close();
    });
  });

  group('OfflineStaleBanner Widget & Localization Tests', () {
    testWidgets('Renders properly in English with retry callback', (tester) async {
      bool refreshed = false;
      final cachedTime = DateTime(2026, 9, 19, 10, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: AppLocalizationsWidget(
            language: AppLanguage.english,
            child: Scaffold(
              body: OfflineStaleBanner(
                cachedAt: cachedTime,
                onRefresh: () {
                  refreshed = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(
        find.textContaining('Offline — showing previously saved information'),
        findsOneWidget,
      );
      expect(find.textContaining('Last updated:'), findsOneWidget);

      // Find retry icon button and tap
      final retryBtn = find.byIcon(Icons.refresh_rounded);
      expect(retryBtn, findsOneWidget);
      await tester.tap(retryBtn);
      expect(refreshed, isTrue);
    });

    testWidgets('Renders properly in Hindi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppLocalizationsWidget(
            language: AppLanguage.hindi,
            child: Scaffold(
              body: OfflineStaleBanner(
                cachedAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      expect(
        find.textContaining('ऑफलाइन — पिछली जानकारी दिखाई जा रही है'),
        findsOneWidget,
      );
      expect(find.textContaining('अंतिम अपडेट:'), findsOneWidget);
    });

    testWidgets('Renders properly in Marathi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppLocalizationsWidget(
            language: AppLanguage.marathi,
            child: Scaffold(
              body: OfflineStaleBanner(
                cachedAt: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      expect(
        find.textContaining('ऑफलाइन — मागील माहिती दाखवत आहोत'),
        findsOneWidget,
      );
      expect(find.textContaining('शेवटचे अपडेट:'), findsOneWidget);
    });
  });
}

int stateLotsCount(RecyclerDashboardLoaded s) => s.lots.length;
