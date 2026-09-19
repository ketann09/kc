import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/entities/material_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/collector_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/materials_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_collector_lots_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_live_scrap_rates_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_lot_details_usecase.dart';
import 'package:kabadiwala_connect/features/collector/collector_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_state.dart';

class FakeCollectorLotsRepository implements CollectorLotsRepository {
  List<LotEntity> lots = [];
  bool shouldFail = false;

  @override
  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (shouldFail) {
      throw ApiException.server(message: 'सर्वर से संपर्क नहीं हो सका');
    }
    return lots;
  }

  @override
  Future<LotEntity> getLotById(String lotId) async {
    return lots.firstWhere(
      (l) => l.id == lotId,
      orElse: () => throw const ApiException(
        message: 'लॉट नहीं मिला',
        type: ApiExceptionType.server,
        statusCode: 404,
      ),
    );
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) =>
      throw UnimplementedError();

  @override
  Future<LotEntity> createLot(CreateLotParams params) =>
      throw UnimplementedError();
}

class FakeMaterialsRepository implements MaterialsRepository {
  List<MaterialEntity> materials = [];
  bool shouldFail = false;

  @override
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) async {
    if (shouldFail) {
      throw ApiException.server(message: 'भाव लोड नहीं हो सके');
    }
    return materials;
  }

  @override
  Future<MaterialEntity> getMaterialById(String id) =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getCategories() async => [
    {'id': '1', 'name': 'pcb'},
  ];
}

class TestCollectorLotsBloc extends CollectorLotsBloc {
  TestCollectorLotsBloc({
    required super.getCollectorLotsUseCase,
    required super.getLotDetailsUseCase,
    required super.getLiveScrapRatesUseCase,
  });

  void emitState(CollectorLotsState s) => emit(s);
}

void main() {
  group('CollectorDashboardScreen Widget Tests', () {
    late FakeCollectorLotsRepository lotsRepo;
    late FakeMaterialsRepository materialsRepo;
    late TestCollectorLotsBloc bloc;

    final testMaterial1 = const MaterialEntity(
      id: 'mat_1',
      name: 'पीसीबी',
      category: 'pcb',
    );

    final testMaterial2 = const MaterialEntity(
      id: 'mat_2',
      name: 'बैटरी',
      category: 'battery',
    );

    final testPendingLot = LotEntity(
      id: 'lot_pending_1',
      collectorId: 'col_1',
      materialName: 'pcb',
      estimatedWeight: 12.5,
      estimatedPrice: 2600.0,
      status: LotStatus.pending,
      createdAt: DateTime(2026, 9, 18),
    );

    final testCompletedLot = LotEntity(
      id: 'lot_completed_1',
      collectorId: 'col_1',
      materialName: 'battery',
      estimatedWeight: 20.0,
      actualWeight: 20.0,
      estimatedPrice: 1700.0,
      finalPrice: 1700.0,
      status: LotStatus.completed,
      createdAt: DateTime(2026, 9, 18),
    );

    setUp(() {
      lotsRepo = FakeCollectorLotsRepository();
      materialsRepo = FakeMaterialsRepository();
      bloc = TestCollectorLotsBloc(
        getCollectorLotsUseCase: GetCollectorLotsUseCase(lotsRepo),
        getLotDetailsUseCase: GetLotDetailsUseCase(lotsRepo),
        getLiveScrapRatesUseCase: GetLiveScrapRatesUseCase(materialsRepo),
      );
    });

    tearDown(() {
      bloc.close();
    });

    Widget createWidgetUnderTest({Map<String, WidgetBuilder>? routes}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        routes: routes ?? {},
        home: BlocProvider<CollectorLotsBloc>.value(
          value: bloc,
          child: const CollectorDashboardScreen(),
        ),
      );
    }

    testWidgets(
      'Renders loading indicator when state is CollectorLotsLoading',
      (tester) async {
        bloc.emitState(const CollectorLotsLoading());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('डैशबोर्ड लोड हो रहा है...'), findsOneWidget);
      },
    );

    testWidgets('Renders failure state with error message and retry button', (
      tester,
    ) async {
      bloc.emitState(const CollectorLotsFailure('डेटा लोड करने में त्रुटि'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('डैशबोर्ड लोड नहीं हो सका'), findsOneWidget);
      expect(find.text('डेटा लोड करने में त्रुटि'), findsOneWidget);
      expect(find.text('पुनः प्रयास करें'), findsOneWidget);
    });

    testWidgets(
      'Renders loaded dashboard with greeting, live rates, and recent lots',
      (tester) async {
        bloc.emitState(
          CollectorDashboardLoaded(
            liveRates: [testMaterial1, testMaterial2],
            recentLots: [testPendingLot, testCompletedLot],
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Greeting
        expect(find.text('नमस्ते, कबाड़ी साथी'), findsOneWidget);
        expect(find.text('आपके पास कबाड़ का भाव, आज के लिए'), findsOneWidget);

        // Recent lots section
        expect(find.text('मेरे हालिया लॉट'), findsOneWidget);
        expect(find.text('सभी देखें'), findsOneWidget);
        expect(find.text('पीसीबी / ई-कचरा'), findsWidgets);
        expect(find.text('लंबित'), findsOneWidget);
        expect(find.text('पूर्ण'), findsOneWidget);
        expect(find.text('12.5 kg'), findsOneWidget);
        expect(find.text('20 kg'), findsOneWidget);

        // Live rates section
        expect(find.text('आज के ताज़ा स्क्रैप भाव'), findsOneWidget);
        expect(find.text('लाइव'), findsOneWidget);

        // CTAs
        expect(find.text('मेरी कमाई और लेन-देन'), findsOneWidget);
        expect(find.text('नया कबाड़ लॉट बनाएं'), findsOneWidget);
      },
    );

    testWidgets('Renders empty state card when recent lots is empty', (
      tester,
    ) async {
      bloc.emitState(
        const CollectorDashboardLoaded(liveRates: [], recentLots: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('अभी कोई कबाड़ लॉट नहीं है'), findsOneWidget);
      expect(
        find.text('नया लॉट जोड़ें और पास के रीसाइक्लर्स से तुरंत ऑफर पाएं'),
        findsOneWidget,
      );
      expect(find.text('लॉट जोड़ें'), findsOneWidget);

      // Default rates rendered on empty live rates
      expect(find.text('आज के ताज़ा स्क्रैप भाव'), findsOneWidget);
      expect(find.text('पीसीबी'), findsOneWidget);
      expect(find.text('बैटरी'), findsOneWidget);
      expect(find.text('केबल'), findsOneWidget);
      expect(find.text('मिश्रित प्लास्टिक'), findsOneWidget);
    });

    testWidgets('Tapping recent lot navigates to /collector-lot-details', (
      tester,
    ) async {
      Map<String, dynamic>? navigatedArgs;

      bloc.emitState(
        CollectorDashboardLoaded(
          liveRates: [testMaterial1],
          recentLots: [testPendingLot],
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            '/collector-lot-details': (context) {
              navigatedArgs =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              return const Scaffold(body: Text('Lot Details Target'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      final lotCard = find.text('पीसीबी / ई-कचरा');
      expect(lotCard, findsWidgets);
      await tester.tap(lotCard.first);
      await tester.pumpAndSettle();

      expect(find.text('Lot Details Target'), findsOneWidget);
      expect(navigatedArgs, isNotNull);
      expect(navigatedArgs!['lotId'], equals('lot_pending_1'));
    });

    testWidgets('Tapping "सभी देखें" navigates to /collector-lots', (
      tester,
    ) async {
      bloc.emitState(
        CollectorDashboardLoaded(liveRates: [], recentLots: [testPendingLot]),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            '/collector-lots': (context) =>
                const Scaffold(body: Text('Collector Lots Target')),
          },
        ),
      );
      await tester.pumpAndSettle();

      final viewAllBtn = find.text('सभी देखें');
      expect(viewAllBtn, findsOneWidget);
      await tester.tap(viewAllBtn);
      await tester.pumpAndSettle();

      expect(find.text('Collector Lots Target'), findsOneWidget);
    });

    testWidgets(
      'Tapping "मेरी कमाई और लेन-देन" navigates to /collector-transactions',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        bloc.emitState(
          const CollectorDashboardLoaded(liveRates: [], recentLots: []),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            routes: {
              '/collector-transactions': (context) =>
                  const Scaffold(body: Text('Collector Transactions Target')),
            },
          ),
        );
        await tester.pumpAndSettle();

        final earningsBtn = find.text('मेरी कमाई और लेन-देन');
        expect(earningsBtn, findsOneWidget);
        await tester.tap(earningsBtn);
        await tester.pumpAndSettle();

        expect(find.text('Collector Transactions Target'), findsOneWidget);
      },
    );

    testWidgets('Tapping "नया कबाड़ लॉट बनाएं" navigates to /new-lot', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bloc.emitState(
        const CollectorDashboardLoaded(liveRates: [], recentLots: []),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            '/new-lot': (context) =>
                const Scaffold(body: Text('New Lot Target')),
          },
        ),
      );
      await tester.pumpAndSettle();

      final newLotBtn = find.text('नया कबाड़ लॉट बनाएं');
      expect(newLotBtn, findsOneWidget);
      await tester.tap(newLotBtn);
      await tester.pumpAndSettle();

      expect(find.text('New Lot Target'), findsOneWidget);
    });
  });
}
