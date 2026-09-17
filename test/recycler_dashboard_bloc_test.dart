import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_event.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_state.dart';

class FakeRecyclerLotsRepository implements RecyclerLotsRepository {
  bool shouldFail = false;
  String failureMessage = 'Backend error';
  List<LotEntity> lotsToReturn = [];

  // Spies
  int getRecyclerLotsCallCount = 0;
  int? lastPage;
  int? lastLimit;
  String? lastStatus;
  String? lastLotId;

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    getRecyclerLotsCallCount++;
    lastPage = page;
    lastLimit = limit;
    lastStatus = status;

    if (shouldFail) {
      throw ApiException.server(message: failureMessage);
    }
    return lotsToReturn;
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    lastLotId = lotId;
    if (lotsToReturn.isNotEmpty) return lotsToReturn.first;
    throw ApiException.unknown(message: 'Not found');
  }
}

void main() {
  late FakeRecyclerLotsRepository fakeRepo;
  late GetRecyclerLotsUseCase useCase;
  late RecyclerDashboardBloc bloc;

  final sampleLot = LotEntity(
    id: 'lot-123',
    collectorId: 'collector-456',
    collectorName: 'राहुल शर्मा',
    materialName: 'प्लास्टिक',
    estimatedWeight: 15.0,
    estimatedPrice: 350.0,
    location: const LotLocationEntity(
      address: 'सेक्टर 62',
      city: 'नोएडा',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.pending,
    createdAt: DateTime(2026, 9, 17, 10, 0),
  );

  setUp(() {
    fakeRepo = FakeRecyclerLotsRepository();
    useCase = GetRecyclerLotsUseCase(fakeRepo);
    bloc = RecyclerDashboardBloc(getRecyclerLotsUseCase: useCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('RecyclerDashboardBloc Tests', () {
    test('1. Initial state is RecyclerDashboardInitial', () {
      expect(bloc.state, isA<RecyclerDashboardInitial>());
    });

    test(
      '2. Successful load emits [Loading, Loaded] with lot entities',
      () async {
        fakeRepo.lotsToReturn = [sampleLot];

        final expectedStates = [
          isA<RecyclerDashboardLoading>(),
          predicate<RecyclerDashboardState>((s) {
            return s is RecyclerDashboardLoaded &&
                s.lots.length == 1 &&
                s.lots.first.id == 'lot-123' &&
                s.lots.first.estimatedPrice == 350.0 &&
                s.currentPage == 1;
          }),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const FetchIncomingLots(page: 1));
      },
    );

    test(
      '3. Empty result emits [Loading, Empty] when no incoming lots returned',
      () async {
        fakeRepo.lotsToReturn = [];

        final expectedStates = [
          isA<RecyclerDashboardLoading>(),
          isA<RecyclerDashboardEmpty>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const FetchIncomingLots(page: 1));
      },
    );

    test('4. Repository/API failure emits [Loading, Failure] with backend error message', () async {
      fakeRepo.shouldFail = true;
      fakeRepo.failureMessage = 'सक्रिय रीसाइक्लर डेटा लोड नहीं हो सका';

      final expectedStates = [
        isA<RecyclerDashboardLoading>(),
        predicate<RecyclerDashboardState>((s) {
          return s is RecyclerDashboardFailure &&
              s.message == 'सक्रिय रीसाइक्लर डेटा लोड नहीं हो सका';
        }),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const FetchIncomingLots(page: 1));
    });

    test('5. Retry re-dispatches fetch and recovers to Loaded state', () async {
      fakeRepo.shouldFail = true;

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecyclerDashboardLoading>(),
          isA<RecyclerDashboardFailure>(),
        ]),
      );

      bloc.add(const FetchIncomingLots(page: 1));
      await pumpEventQueue();

      // Now fix failure and trigger retry
      fakeRepo.shouldFail = false;
      fakeRepo.lotsToReturn = [sampleLot];

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecyclerDashboardLoading>(),
          predicate<RecyclerDashboardState>((s) {
            return s is RecyclerDashboardLoaded && s.lots.length == 1;
          }),
        ]),
      );

      bloc.add(const FetchIncomingLots(page: 1, refresh: true));
    });

    test('6. Correct repository method invocation with arguments', () async {
      fakeRepo.lotsToReturn = [sampleLot];

      bloc.add(const FetchIncomingLots(page: 2, limit: 15, status: 'pending'));
      await pumpEventQueue();

      expect(fakeRepo.getRecyclerLotsCallCount, 1);
      expect(fakeRepo.lastPage, 2);
      expect(fakeRepo.lastLimit, 15);
      expect(fakeRepo.lastStatus, 'pending');
    });

    test(
      '7. DashboardStarted triggers fetch with default pagination',
      () async {
        fakeRepo.lotsToReturn = [sampleLot];

        bloc.add(const DashboardStarted());
        await pumpEventQueue();

        expect(fakeRepo.getRecyclerLotsCallCount, 1);
        expect(fakeRepo.lastPage, 1);
        expect(fakeRepo.lastLimit, 10);
        expect(bloc.state, isA<RecyclerDashboardLoaded>());
      },
    );
  });
}
