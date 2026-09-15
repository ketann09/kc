import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/entities/matched_recycler_entity.dart';
import 'package:kabadiwala_connect/domain/entities/matchmaking_result_entity.dart';
import 'package:kabadiwala_connect/domain/entities/material_entity.dart';
import 'package:kabadiwala_connect/domain/entities/ml_classification_entity.dart';
import 'package:kabadiwala_connect/domain/entities/ml_predict_and_price_result_entity.dart';
import 'package:kabadiwala_connect/domain/entities/ml_price_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/collector_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/matchmaking_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/materials_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/ml_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/classify_scrap_image_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/create_collector_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/estimate_price_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_collector_lots_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_live_scrap_rates_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_lot_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_matched_recyclers_usecase.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_state.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/matchmaking/matchmaking_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/matchmaking/matchmaking_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/matchmaking/matchmaking_state.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_state.dart';

// ==========================================
// FAKE REPOSITORIES
// ==========================================

class FakeMLRepository implements MLRepository {
  bool shouldFailClassify = false;
  bool shouldFailPrice = false;

  @override
  Future<MLClassificationEntity> classifyImage({
    required String imagePath,
  }) async {
    if (shouldFailClassify) {
      throw ApiException.server(message: 'AI Model unreachable');
    }
    return const MLClassificationEntity(
      category: 'Plastic',
      confidence: 0.94,
      confidencePercent: 94.0,
    );
  }

  @override
  Future<MLPriceEntity> predictPrice({
    required String category,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) async {
    if (shouldFailPrice) {
      throw ApiException.server(message: 'Price prediction failed');
    }
    return MLPriceEntity(
      category: category,
      recommendedRateInr: 25.0,
      estimatedValueInr: 25.0 * totalWeightKg,
      estimatedValueMinInr: 23.0 * totalWeightKg,
      estimatedValueMaxInr: 27.0 * totalWeightKg,
    );
  }

  @override
  Future<MLPredictAndPriceResultEntity> predictAndPrice({
    required String imagePath,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) async {
    final c = await classifyImage(imagePath: imagePath);
    final p = await predictPrice(
      category: c.category,
      state: state,
      city: city,
      quantity: quantity,
      totalWeightKg: totalWeightKg,
    );
    return MLPredictAndPriceResultEntity(classification: c, pricing: p);
  }

  @override
  Future<List<String>> getCategories() async {
    return ['Plastic', 'Paper', 'Metal', 'E-Waste'];
  }
}

class FakeCollectorLotsRepository implements CollectorLotsRepository {
  bool shouldFailCreate = false;
  bool shouldFailFetch = false;
  bool shouldFailDetails = false;

  final testLot = const LotEntity(
    id: 'lot_real_123',
    collectorId: 'collector_999',
    estimatedWeight: 5.0,
    estimatedPrice: 125.0,
    images: ['uploads/lot1.jpg'],
  );

  @override
  Future<LotEntity> createLot(CreateLotParams params) async {
    if (shouldFailCreate) {
      throw ApiException.server(message: 'Failed to create lot on server');
    }
    return LotEntity(
      id: 'lot_real_123',
      collectorId: 'collector_999',
      estimatedWeight: params.estimatedWeight,
      estimatedPrice: params.estimatedPrice ?? 0.0,
      location: params.location,
      images: params.imagePaths,
      description: params.description,
    );
  }

  @override
  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldFailFetch) {
      throw ApiException.server(message: 'Failed to fetch collector lots');
    }
    return [testLot];
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    if (shouldFailDetails) {
      throw ApiException.server(message: 'Lot not found');
    }
    return testLot;
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async {
    return testLot;
  }
}

class FakeMatchmakingRepository implements MatchmakingRepository {
  bool shouldFail = false;
  bool returnEmpty = false;

  final testRecycler = const MatchedRecyclerEntity(
    recyclerId: 'rec_456',
    recyclerName: 'Green Recycle Hub',
    price: 130.0,
    distance: 2.5,
    score: 95.0,
  );

  @override
  Future<MatchmakingResultEntity> findRecyclersForLot(String lotId) async {
    if (shouldFail) {
      throw ApiException.server(message: 'Matchmaking service down');
    }
    if (returnEmpty) {
      return MatchmakingResultEntity(lotId: lotId, matches: const []);
    }
    return MatchmakingResultEntity(
      lotId: lotId,
      matches: [testRecycler],
      bestMatch: testRecycler,
    );
  }

  @override
  Future<MatchmakingResultEntity> autoMatchLot(String lotId) async {
    return findRecyclersForLot(lotId);
  }
}

class FakeMaterialsRepository implements MaterialsRepository {
  bool shouldFail = false;

  final testMaterial = const MaterialEntity(
    id: 'mat_1',
    name: 'PET Bottles',
    category: 'plastic',
  );

  @override
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) async {
    if (shouldFail) {
      throw ApiException.server(message: 'Failed to fetch materials');
    }
    return [testMaterial];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return [
      {'id': 'plastic', 'name': 'Plastic'},
    ];
  }

  @override
  Future<MaterialEntity> getMaterialById(String materialId) async {
    return testMaterial;
  }
}

// ==========================================
// TESTS
// ==========================================

void main() {
  group('NewLotBloc Tests', () {
    late FakeMLRepository fakeML;
    late FakeCollectorLotsRepository fakeLots;
    late NewLotBloc bloc;

    setUp(() {
      fakeML = FakeMLRepository();
      fakeLots = FakeCollectorLotsRepository();
      bloc = NewLotBloc(
        classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
        estimatePriceUseCase: EstimatePriceUseCase(fakeML),
        createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state has NewLotStatus.initial and defaults', () {
      expect(bloc.state.status, equals(NewLotStatus.initial));
      expect(bloc.state.weightKg, equals(1.0));
      expect(bloc.state.quantity, equals(1));
    });

    test('Classification success emits classifying then classified', () async {
      final expected = [
        const NewLotState(
          status: NewLotStatus.classifying,
          imagePath: 'path/to/img.jpg',
        ),
        const NewLotState(
          status: NewLotStatus.classified,
          imagePath: 'path/to/img.jpg',
          category: 'Plastic',
          classification: MLClassificationEntity(
            category: 'Plastic',
            confidence: 0.94,
            confidencePercent: 94.0,
          ),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const NewLotImageSelected('path/to/img.jpg'));
    });

    test(
      'Classification failure preserves image and produces actionable error',
      () async {
        fakeML.shouldFailClassify = true;

        final expected = [
          const NewLotState(
            status: NewLotStatus.classifying,
            imagePath: 'path/to/img.jpg',
          ),
          const NewLotState(
            status: NewLotStatus.failure,
            errorType: NewLotErrorType.classification,
            errorMessage: 'AI Model unreachable',
            imagePath: 'path/to/img.jpg',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const NewLotImageSelected('path/to/img.jpg'));
      },
    );

    test('Pricing success updates priceEstimate without clearing classification or image', () async {
      // First classify
      bloc.add(const NewLotImageSelected('path/to/img.jpg'));
      await Future.delayed(const Duration(milliseconds: 10));

      // Then request price
      bloc.add(
        const NewLotEstimatePriceRequested(
          state: 'Maharashtra',
          city: 'Mumbai',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<NewLotState>(
            (s) =>
                s.status == NewLotStatus.priced &&
                s.priceEstimate != null &&
                s.imagePath == 'path/to/img.jpg' &&
                s.category == 'Plastic',
          ),
        ),
      );
    });

    test(
      'Pricing failure does not destroy image or classification state',
      () async {
        bloc.add(const NewLotImageSelected('path/to/img.jpg'));
        await Future.delayed(const Duration(milliseconds: 10));

        fakeML.shouldFailPrice = true;
        bloc.add(
          const NewLotEstimatePriceRequested(
            state: 'Maharashtra',
            city: 'Mumbai',
          ),
        );

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<NewLotState>(
              (s) =>
                  s.status == NewLotStatus.failure &&
                  s.errorType == NewLotErrorType.pricing &&
                  s.imagePath == 'path/to/img.jpg' &&
                  s.category == 'Plastic',
            ),
          ),
        );
      },
    );

    test('Lot creation success exposes real LotEntity.id', () async {
      bloc.add(const NewLotImageSelected('path/to/img.jpg'));
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(
        const NewLotSubmitted(
          location: LotLocationEntity(city: 'Mumbai', state: 'Maharashtra'),
          description: 'Clean plastic bottles',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<NewLotState>(
            (s) =>
                s.status == NewLotStatus.success &&
                s.createdLot?.id == 'lot_real_123',
          ),
        ),
      );
    });

    test(
      'Lot creation failure allows retry with preserved form state',
      () async {
        bloc.add(const NewLotImageSelected('path/to/img.jpg'));
        await Future.delayed(const Duration(milliseconds: 10));

        fakeLots.shouldFailCreate = true;
        bloc.add(
          const NewLotSubmitted(
            location: LotLocationEntity(city: 'Mumbai', state: 'Maharashtra'),
          ),
        );

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<NewLotState>(
              (s) =>
                  s.status == NewLotStatus.failure &&
                  s.errorType == NewLotErrorType.submission &&
                  s.imagePath == 'path/to/img.jpg' &&
                  s.category == 'Plastic',
            ),
          ),
        );
      },
    );

    test('Preserves state when weight and category are changed', () async {
      bloc.add(const NewLotImageSelected('path/to/img.jpg'));
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(const NewLotCategoryChanged(category: 'Metal'));
      bloc.add(const NewLotWeightQuantityChanged(weightKg: 15.0, quantity: 2));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<NewLotState>(
            (s) =>
                s.imagePath == 'path/to/img.jpg' &&
                s.category == 'Metal' &&
                s.weightKg == 15.0 &&
                s.quantity == 2,
          ),
        ),
      );
    });
  });

  group('MatchmakingBloc Tests', () {
    late FakeMatchmakingRepository fakeMatchmaking;
    late MatchmakingBloc bloc;

    setUp(() {
      fakeMatchmaking = FakeMatchmakingRepository();
      bloc = MatchmakingBloc(
        getMatchedRecyclersUseCase: GetMatchedRecyclersUseCase(fakeMatchmaking),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is MatchmakingInitial', () {
      expect(bloc.state, equals(const MatchmakingInitial()));
    });

    test(
      'Matchmaking success emits loading then loaded with recyclers',
      () async {
        final expected = [
          const MatchmakingLoading(),
          MatchmakingLoaded(
            lotId: 'lot_real_123',
            matches: [fakeMatchmaking.testRecycler],
            bestMatch: fakeMatchmaking.testRecycler,
            selectedRecycler: fakeMatchmaking.testRecycler,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const FetchMatchedRecyclersEvent('lot_real_123'));
      },
    );

    test(
      'Matchmaking empty emits MatchmakingEmpty when no recyclers found',
      () async {
        fakeMatchmaking.returnEmpty = true;

        final expected = [
          const MatchmakingLoading(),
          const MatchmakingEmpty(lotId: 'lot_real_123'),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const FetchMatchedRecyclersEvent('lot_real_123'));
      },
    );

    test('Matchmaking failure emits MatchmakingFailure on API error', () async {
      fakeMatchmaking.shouldFail = true;

      final expected = [
        const MatchmakingLoading(),
        const MatchmakingFailure(
          lotId: 'lot_real_123',
          message: 'Matchmaking service down',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const FetchMatchedRecyclersEvent('lot_real_123'));
    });

    test(
      'SelectRecycler updates presentation-only selection without API call',
      () async {
        bloc.add(const FetchMatchedRecyclersEvent('lot_real_123'));
        await Future.delayed(const Duration(milliseconds: 10));

        const alternateRecycler = MatchedRecyclerEntity(
          recyclerId: 'rec_alt',
          recyclerName: 'Alternate Recycler',
          price: 135.0,
        );

        bloc.add(const SelectRecyclerEvent(alternateRecycler));

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<MatchmakingState>(
              (s) =>
                  s is MatchmakingLoaded &&
                  s.selectedRecycler?.recyclerId == 'rec_alt',
            ),
          ),
        );
      },
    );
  });

  group('CollectorLotsBloc Tests', () {
    late FakeCollectorLotsRepository fakeLots;
    late FakeMaterialsRepository fakeMaterials;
    late CollectorLotsBloc bloc;

    setUp(() {
      fakeLots = FakeCollectorLotsRepository();
      fakeMaterials = FakeMaterialsRepository();
      bloc = CollectorLotsBloc(
        getCollectorLotsUseCase: GetCollectorLotsUseCase(fakeLots),
        getLotDetailsUseCase: GetLotDetailsUseCase(fakeLots),
        getLiveScrapRatesUseCase: GetLiveScrapRatesUseCase(fakeMaterials),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is CollectorLotsInitial', () {
      expect(bloc.state, equals(const CollectorLotsInitial()));
    });

    test(
      'Dashboard init emits loading then CollectorDashboardLoaded',
      () async {
        final expected = [
          const CollectorLotsLoading(),
          CollectorDashboardLoaded(
            liveRates: [fakeMaterials.testMaterial],
            recentLots: [fakeLots.testLot],
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const CollectorDashboardInitRequested());
      },
    );

    test('Lots fetch success emits CollectorLotsLoaded', () async {
      final expected = [
        const CollectorLotsLoading(),
        CollectorLotsLoaded(
          lots: [fakeLots.testLot],
          currentPage: 1,
          hasReachedMax: true,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CollectorLotsFetchRequested());
    });

    test('Lots fetch failure emits CollectorLotsFailure', () async {
      fakeLots.shouldFailFetch = true;

      final expected = [
        const CollectorLotsLoading(),
        const CollectorLotsFailure('Failed to fetch collector lots'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CollectorLotsFetchRequested());
    });

    test('Lot detail fetch success emits CollectorLotDetailLoaded', () async {
      final expected = [
        const CollectorLotsLoading(),
        CollectorLotDetailLoaded(fakeLots.testLot),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CollectorLotDetailsRequested('lot_real_123'));
    });
  });
}
