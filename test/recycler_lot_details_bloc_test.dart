import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
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
}

void main() {
  late FakeRecyclerLotsRepository fakeRepo;
  late GetRecyclerLotDetailsUseCase getUseCase;
  late AcceptRecyclerLotUseCase acceptUseCase;
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

  setUp(() {
    fakeRepo = FakeRecyclerLotsRepository();
    getUseCase = GetRecyclerLotDetailsUseCase(fakeRepo);
    acceptUseCase = AcceptRecyclerLotUseCase(fakeRepo);
    bloc = RecyclerLotDetailsBloc(
      getRecyclerLotDetailsUseCase: getUseCase,
      acceptRecyclerLotUseCase: acceptUseCase,
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

    test(
      '6. Successful AcceptRecyclerLotEvent emits isAccepting true then false with status accepted and success message',
      () async {
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
      },
    );

    test(
      '7. Failed AcceptRecyclerLotEvent retains lot data and sets actionErrorMessage',
      () async {
        fakeRepo.lotToReturn = sampleLot;

        // First load lot
        bloc.add(const FetchRecyclerLotDetailsEvent('lot-xyz-999'));
        await pumpEventQueue();
        expect(bloc.state, isA<RecyclerLotDetailsLoaded>());

        // Now configure failure
        fakeRepo.shouldFail = true;
        fakeRepo.failureMessage = 'लॉट पहले ही किसी अन्य रीसाइक्लर द्वारा स्वीकार किया जा चुका है';

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
      },
    );

    test('8. AcceptRecyclerLotEvent passes correct lotId and optional price to repository', () async {
      final acceptedLot = acceptedSampleLot;
      fakeRepo.lotToReturn = sampleLot;

      bloc.add(const FetchRecyclerLotDetailsEvent('lot-target-123'));
      await pumpEventQueue();

      fakeRepo.lotToReturn = acceptedLot;
      bloc.add(const AcceptRecyclerLotEvent(lotId: 'lot-target-123', price: 12500.0));
      await pumpEventQueue();

      expect(fakeRepo.acceptLotCallCount, 1);
      expect(fakeRepo.lastAcceptLotId, 'lot-target-123');
      expect(fakeRepo.lastAcceptPrice, 12500.0);
    });
  });
}
