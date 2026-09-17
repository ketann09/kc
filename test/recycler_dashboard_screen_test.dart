import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/recycler_dashboard_state.dart';
import 'package:kabadiwala_connect/features/recycler/recycler_dashboard_screen.dart';

class MockRecyclerLotsRepository implements RecyclerLotsRepository {
  bool shouldFail = false;
  String errorMessage = 'नेटवर्क त्रुटि';
  List<LotEntity> lots = [];

  int fetchCount = 0;

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    fetchCount++;
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    return lots;
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    if (lots.isNotEmpty) return lots.first;
    throw Exception('Lot not found');
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async {
    if (lots.isNotEmpty) return lots.first;
    throw Exception('Lot not found');
  }

  @override
  Future<LotEntity> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) async {
    if (lots.isNotEmpty) return lots.first;
    throw Exception('Lot not found');
  }
}

void main() {
  late MockRecyclerLotsRepository fakeRepo;
  late GetRecyclerLotsUseCase useCase;
  late RecyclerDashboardBloc bloc;

  final sampleLot = LotEntity(
    id: 'lot-abc-123',
    collectorId: 'collector-789',
    collectorName: 'राहुल शर्मा',
    materialName: 'मिश्रित प्लास्टिक',
    estimatedWeight: 15.0,
    estimatedPrice: 350.0,
    location: const LotLocationEntity(
      address: 'सेक्टर 62',
      city: 'नोएडा',
      state: 'उत्तर प्रदेश',
    ),
    status: LotStatus.pending,
    schedulePickup: const {'pickup': true},
    createdAt: DateTime(2026, 9, 17),
  );

  setUp(() {
    fakeRepo = MockRecyclerLotsRepository();
    useCase = GetRecyclerLotsUseCase(fakeRepo);
    bloc = RecyclerDashboardBloc(getRecyclerLotsUseCase: useCase);
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildTestApp({
    RecyclerDashboardBloc? providedBloc,
    RouteFactory? onGenerateRoute,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: onGenerateRoute,
      home: BlocProvider<RecyclerDashboardBloc>.value(
        value: providedBloc ?? bloc,
        child: const RecyclerDashboardScreen(),
      ),
    );
  }

  group('RecyclerDashboardScreen Widget Tests', () {
    testWidgets('1. Displays loading state with spinner and caption', (
      tester,
    ) async {
      bloc.emit(const RecyclerDashboardLoading());
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('लॉट लोड हो रहे हैं...'), findsOneWidget);
    });

    testWidgets(
      '2. Displays empty state with icon, message, and refresh button',
      (tester) async {
        bloc.emit(const RecyclerDashboardEmpty());
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
        expect(find.text('अभी कोई नया लॉट नहीं है'), findsOneWidget);
        expect(find.text('नए लॉट अनुरोध यहाँ दिखाई देंगे।'), findsOneWidget);
        expect(find.text('रिफ्रेश करें'), findsOneWidget);
      },
    );

    testWidgets('3. Displays loaded state with real LotEntity details', (
      tester,
    ) async {
      bloc.emit(RecyclerDashboardLoaded(lots: [sampleLot]));
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Material name
      expect(find.text('मिश्रित प्लास्टिक'), findsOneWidget);

      // Status badge
      expect(find.text('लंबित'), findsOneWidget);

      // Direct estimated price (no derivation)
      expect(find.text('₹350'), findsOneWidget);

      // Weight & collector info
      expect(
        find.text('15 किलो · राहुल शर्मा द्वारा भेजा गया'),
        findsOneWidget,
      );

      // Location
      expect(find.text('नोएडा, उत्तर प्रदेश'), findsOneWidget);

      // Pickup badge
      expect(find.text('पिकअप अनुरोध'), findsOneWidget);
    });

    testWidgets(
      '4. Displays failure state with message and retry button triggers fetch',
      (tester) async {
        bloc.emit(
          const RecyclerDashboardFailure('सर्वर से संपर्क नहीं हो सका'),
        );
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('लॉट लोड करने में समस्या'), findsOneWidget);
        expect(find.text('सर्वर से संपर्क नहीं हो सका'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Tap retry
        fakeRepo.lots = [sampleLot];
        await tester.tap(find.text('पुनः प्रयास करें'));
        await tester.pump();

        expect(bloc.state, isA<RecyclerDashboardLoading>());
      },
    );

    testWidgets('5. Tapping lot card navigates with real lotId', (
      tester,
    ) async {
      dynamic receivedRouteArgs;
      String? pushedRouteName;

      bloc.emit(RecyclerDashboardLoaded(lots: [sampleLot]));
      await tester.pumpWidget(
        buildTestApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/incoming-lot') {
              pushedRouteName = settings.name;
              receivedRouteArgs = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Details Screen')),
              );
            }
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('मिश्रित प्लास्टिक'));
      await tester.pumpAndSettle();

      expect(pushedRouteName, '/incoming-lot');
      expect(receivedRouteArgs, 'lot-abc-123');
      expect(find.text('Details Screen'), findsOneWidget);
    });
  });
}
