import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/update_lot_lifecycle_usecase.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_event.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_state.dart';

class FakeRecyclerLotsRepository implements RecyclerLotsRepository {
  bool shouldFail = false;
  String failureMessage = 'Backend error';
  LotEntity? lotToReturn;

  // Spies
  int getLotByIdCallCount = 0;
  String? lastLotId;
  int acceptLotCallCount = 0;
  String? lastAcceptLotId;
  double? lastAcceptPrice;
  int updateLotLifecycleCallCount = 0;
  String? lastUpdateLotId;
  String? lastUpdateStatus;
  double? lastUpdateActualWeight;
  double? lastUpdateFinalPrice;

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return [];
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    getLotByIdCallCount++;
    lastLotId = lotId;

    if (shouldFail) {
      throw ApiException.server(message: failureMessage);
    }
    if (lotToReturn != null) {
      return lotToReturn!;
    }
    throw ApiException.unknown(message: 'Lot not found');
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async {
    acceptLotCallCount++;
    lastAcceptLotId = lotId;
    lastAcceptPrice = price;

    if (shouldFail) {
      throw ApiException.server(message: failureMessage);
    }
    if (lotToReturn != null) {
      return lotToReturn!;
    }
    throw ApiException.unknown(message: 'Lot not found');
  }

  @override
  Future<LotEntity> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) async {
    updateLotLifecycleCallCount++;
    lastUpdateLotId = lotId;
    lastUpdateStatus = status;
    lastUpdateActualWeight = actualWeight;
    lastUpdateFinalPrice = finalPrice;

    if (shouldFail) {
      throw ApiException.server(message: failureMessage);
    }
    if (lotToReturn != null) {
      return lotToReturn!;
    }
    throw ApiException.unknown(message: 'Lot not found');
  }
}

void main() {
  late FakeRecyclerLotsRepository fakeRepo;
  late GetRecyclerLotDetailsUseCase getUseCase;
  late AcceptRecyclerLotUseCase acceptUseCase;
  late UpdateLotLifecycleUseCase updateUseCase;
  late RecyclerLotDetailsBloc bloc;

  final sampleLot = LotEntity(
    id: 'lot-xyz-999',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    collectorPhone: '9876543210',
    materialName: 'तांबा वायर',
    estimatedWeight: 25.0,
    estimatedPrice: 12500.0,
    location: const LotLocationEntity(
      address: 'गली 4, मोहन नगर',
      city: 'गाजियाबाद',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.pending,
    description: 'शुद्ध तांबा वायर 25 किलो',
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17, 12, 30),
  );

  final acceptedSampleLot = LotEntity(
    id: 'lot-xyz-999',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    collectorPhone: '9876543210',
    materialName: 'तांबा वायर',
    estimatedWeight: 25.0,
    estimatedPrice: 12500.0,
    location: const LotLocationEntity(
      address: 'गली 4, मोहन नगर',
      city: 'गाजियाबाद',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.accepted,
    description: 'शुद्ध तांबा वायर 25 किलो',
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17, 12, 30),
  );

  final pickedSampleLot = LotEntity(
    id: 'lot-xyz-999',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    collectorPhone: '9876543210',
    materialName: 'तांबा वायर',
    estimatedWeight: 25.0,
    estimatedPrice: 12500.0,
    location: const LotLocationEntity(
      address: 'गली 4, मोहन नगर',
      city: 'गाजियाबाद',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.picked,
    description: 'शुद्ध तांबा वायर 25 किलो',
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17, 12, 30),
  );

  final deliveredSampleLot = LotEntity(
    id: 'lot-xyz-999',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    collectorPhone: '9876543210',
    materialName: 'तांबा वायर',
    estimatedWeight: 25.0,
    estimatedPrice: 12500.0,
    location: const LotLocationEntity(
      address: 'गली 4, मोहन नगर',
      city: 'गाजियाबाद',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.delivered,
    description: 'शुद्ध तांबा वायर 25 किलो',
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17, 12, 30),
  );

  final completedSampleLot = LotEntity(
    id: 'lot-xyz-999',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    collectorPhone: '9876543210',
    materialName: 'तांबा वायर',
    estimatedWeight: 25.0,
    actualWeight: 25.0,
    estimatedPrice: 12500.0,
    finalPrice: 12500.0,
    location: const LotLocationEntity(
      address: 'गली 4, मोहन नगर',
      city: 'गाजियाबाद',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.completed,
    description: 'शुद्ध तांबा वायर 25 किलो',
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17, 12, 30),
  );

  setUp(() {
    fakeRepo = FakeRecyclerLotsRepository();
    getUseCase = GetRecyclerLotDetailsUseCase(fakeRepo);
    acceptUseCase = AcceptRecyclerLotUseCase(fakeRepo);
    updateUseCase = UpdateLotLifecycleUseCase(fakeRepo);
    bloc = RecyclerLotDetailsBloc(
      getRecyclerLotDetailsUseCase: getUseCase,
      acceptRecyclerLotUseCase: acceptUseCase,
      updateLotLifecycleUseCase: updateUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('RecyclerLotDetailsBloc Tests', () {
    test('1. Initial state is RecyclerLotDetailsInitial', () {
      expect(bloc.state, isA<RecyclerLotDetailsInitial>());
    });

    test(
      '2. Successful fetch emits [Loading, Loaded] with real LotEntity',
      () async {
        fakeRepo.lotToReturn = sampleLot;

        final expectedStates = [
          isA<RecyclerLotDetailsLoading>(),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.lot.id == 'lot-xyz-999' &&
                s.lot.materialName == 'तांबा वायर' &&
                s.lot.estimatedPrice == 12500.0 &&
                s.lot.estimatedWeight == 25.0;
          }),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      },
    );

    test(
      '3. API failure emits [Loading, Failure] with backend error message',
      () async {
        fakeRepo.shouldFail = true;
        fakeRepo.failureMessage = 'लॉट उपलब्ध नहीं है';

        final expectedStates = [
          isA<RecyclerLotDetailsLoading>(),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsFailure &&
                s.message == 'लॉट उपलब्ध नहीं है';
          }),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      },
    );

    test(
      '4. Retry invokes repository again and recovers to Loaded state',
      () async {
        fakeRepo.shouldFail = true;

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<RecyclerLotDetailsLoading>(),
            isA<RecyclerLotDetailsFailure>(),
          ]),
        );

        bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
        await pumpEventQueue();

        // Fix failure and retry
        fakeRepo.shouldFail = false;
        fakeRepo.lotToReturn = sampleLot;

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<RecyclerLotDetailsLoading>(),
            predicate<RecyclerLotDetailsState>((s) {
              return s is RecyclerLotDetailsLoaded && s.lot.id == 'lot-xyz-999';
            }),
          ]),
        );

        bloc.add(const RetryRecyclerLotDetailsEvent('lot-xyz-999'));
      },
    );

    test('5. Correct lotId passed to repository/usecase', () async {
      fakeRepo.lotToReturn = sampleLot;

      bloc.add(const FetchRecyclerLotDetailsEvent('lot-unique-id-777'));
      await pumpEventQueue();

      expect(fakeRepo.getLotByIdCallCount, 1);
      expect(fakeRepo.lastLotId, 'lot-unique-id-777');
    });

    test('6. Successful AcceptRecyclerLotEvent emits isAccepting true then false with status accepted and success message', () async {
      final acceptedLot = acceptedSampleLot;
      fakeRepo.lotToReturn = sampleLot;

      // First load lot
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();
      expect(bloc.state, isA<RecyclerLotDetailsLoaded>());

      // Now prepare accept response
      fakeRepo.lotToReturn = acceptedLot;

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded && s.isAccepting == true;
          }),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isAccepting == false &&
                s.lot.status == LotStatus.accepted &&
                s.actionSuccessMessage != null;
          }),
        ]),
      );

      bloc.add(const AcceptRecyclerLotEvent(lotId: 'lot-xyz-999'));
    });

    test('7. Failed AcceptRecyclerLotEvent retains lot data and sets actionErrorMessage', () async {
      fakeRepo.lotToReturn = sampleLot;

      // First load lot
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();
      expect(bloc.state, isA<RecyclerLotDetailsLoaded>());

      // Now configure failure
      fakeRepo.shouldFail = true;
      fakeRepo.failureMessage =
          'लॉट पहले ही किसी अन्य रीसाइक्लर द्वारा स्वीकार किया जा चुका है';

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded && s.isAccepting == true;
          }),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isAccepting == false &&
                s.lot.status == LotStatus.pending &&
                s.actionErrorMessage ==
                    'लॉट पहले ही किसी अन्य रीसाइक्लर द्वारा स्वीकार किया जा चुका है';
          }),
        ]),
      );

      bloc.add(const AcceptRecyclerLotEvent(lotId: 'lot-xyz-999'));
    });

    test('8. AcceptRecyclerLotEvent passes correct lotId and optional price to repository', () async {
      final acceptedLot = acceptedSampleLot;
      fakeRepo.lotToReturn = sampleLot;

      bloc.add(const FetchRecyclerLotDetailsEvent('lot-target-123'));
      await pumpEventQueue();

      fakeRepo.lotToReturn = acceptedLot;
      bloc.add(
        const AcceptRecyclerLotEvent(lotId: 'lot-target-123', price: 12500.0),
      );
      await pumpEventQueue();

      expect(fakeRepo.acceptLotCallCount, 1);
      expect(fakeRepo.lastAcceptLotId, 'lot-target-123');
      expect(fakeRepo.lastAcceptPrice, 12500.0);
    });

    test('9. Lifecycle A: accepted -> picked sends status "picked" and correct lotId', () async {
      fakeRepo.lotToReturn = acceptedSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      fakeRepo.lotToReturn = pickedSampleLot;
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'picked',
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 1);
      expect(fakeRepo.lastUpdateLotId, 'lot-xyz-999');
      expect(fakeRepo.lastUpdateStatus, 'picked');
    });

    test(
      '10. Lifecycle B: picked -> delivered sends status "delivered"',
      () async {
        fakeRepo.lotToReturn = pickedSampleLot;
        bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
        await pumpEventQueue();

        fakeRepo.lotToReturn = deliveredSampleLot;
        bloc.add(
          const UpdateRecyclerLotLifecycleEvent(
            lotId: 'lot-xyz-999',
            status: 'delivered',
          ),
        );
        await pumpEventQueue();

        expect(fakeRepo.updateLotLifecycleCallCount, 1);
        expect(fakeRepo.lastUpdateLotId, 'lot-xyz-999');
        expect(fakeRepo.lastUpdateStatus, 'delivered');
      },
    );

    test('11. Lifecycle C: delivered -> completed passes positive actualWeight correctly', () async {
      fakeRepo.lotToReturn = deliveredSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      fakeRepo.lotToReturn = completedSampleLot;
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'completed',
          actualWeight: 25.0,
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 1);
      expect(fakeRepo.lastUpdateLotId, 'lot-xyz-999');
      expect(fakeRepo.lastUpdateStatus, 'completed');
      expect(fakeRepo.lastUpdateActualWeight, 25.0);
    });

    test('12. Lifecycle D: completion with null actualWeight fails locally without calling repository', () async {
      fakeRepo.lotToReturn = deliveredSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'completed',
          actualWeight: null,
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 0);
      final currentState = bloc.state as RecyclerLotDetailsLoaded;
      expect(currentState.isUpdatingLifecycle, isFalse);
      expect(currentState.actionErrorMessage, isNotNull);
      expect(currentState.lot.status, LotStatus.delivered);
    });

    test('13. Lifecycle E: completion with actualWeight <= 0 fails locally without calling repository', () async {
      fakeRepo.lotToReturn = deliveredSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      // Test with 0
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'completed',
          actualWeight: 0,
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 0);
      var currentState = bloc.state as RecyclerLotDetailsLoaded;
      expect(currentState.isUpdatingLifecycle, isFalse);
      expect(currentState.actionErrorMessage, isNotNull);

      // Test with negative
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'completed',
          actualWeight: -5.0,
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 0);
      currentState = bloc.state as RecyclerLotDetailsLoaded;
      expect(currentState.isUpdatingLifecycle, isFalse);
      expect(currentState.actionErrorMessage, isNotNull);
    });

    test('14. Lifecycle F: successful update emits loading state, replaces lot, and exposes success message', () async {
      fakeRepo.lotToReturn = acceptedSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();
      expect(bloc.state, isA<RecyclerLotDetailsLoaded>());

      fakeRepo.lotToReturn = pickedSampleLot;

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isUpdatingLifecycle == true;
          }),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isUpdatingLifecycle == false &&
                s.lot.status == LotStatus.picked &&
                s.actionSuccessMessage != null;
          }),
        ]),
      );

      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'picked',
        ),
      );
    });

    test('15. Lifecycle G: failed update keeps existing lot intact, ends loading, and exposes error message', () async {
      fakeRepo.lotToReturn = acceptedSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();
      expect(bloc.state, isA<RecyclerLotDetailsLoaded>());

      fakeRepo.shouldFail = true;
      fakeRepo.failureMessage = 'लॉट स्थिति अपडेट करने में असमर्थ';

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isUpdatingLifecycle == true;
          }),
          predicate<RecyclerLotDetailsState>((s) {
            return s is RecyclerLotDetailsLoaded &&
                s.isUpdatingLifecycle == false &&
                s.lot.status == LotStatus.accepted &&
                s.actionErrorMessage == 'लॉट स्थिति अपडेट करने में असमर्थ';
          }),
        ]),
      );

      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'picked',
        ),
      );
    });

    test('16. Lifecycle H: finalPrice is passed through unchanged when explicitly supplied', () async {
      fakeRepo.lotToReturn = deliveredSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      fakeRepo.lotToReturn = completedSampleLot;
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'completed',
          actualWeight: 25.0,
          finalPrice: 15500.0,
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 1);
      expect(fakeRepo.lastUpdateFinalPrice, 15500.0);
    });

    test('17. Lifecycle: duplicate event is ignored while isUpdatingLifecycle is true', () async {
      fakeRepo.lotToReturn = acceptedSampleLot;
      bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
      await pumpEventQueue();

      // Emit state with isUpdatingLifecycle true
      bloc.emit(
        (bloc.state as RecyclerLotDetailsLoaded).copyWith(
          isUpdatingLifecycle: true,
        ),
      );

      // Attempting update while already loading
      bloc.add(
        const UpdateRecyclerLotLifecycleEvent(
          lotId: 'lot-xyz-999',
          status: 'picked',
        ),
      );
      await pumpEventQueue();

      expect(fakeRepo.updateLotLifecycleCallCount, 0);
    });
  });
}
