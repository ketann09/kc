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
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/collector_lots/collector_lots_state.dart';
import 'package:kabadiwala_connect/features/collector/presentation/screens/collector_lots_screen.dart';

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
      throw ApiException.server(message: 'लॉट लोड नहीं हो सके');
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
  @override
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) async => [];

  @override
  Future<MaterialEntity> getMaterialById(String id) =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getCategories() async => [];
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
  group('CollectorLotsScreen Widget Tests', () {
    late FakeCollectorLotsRepository lotsRepo;
    late FakeMaterialsRepository materialsRepo;
    late TestCollectorLotsBloc bloc;

    final testPendingLot = LotEntity(
      id: 'lot_pending_1',
      collectorId: 'col_1',
      materialName: 'pcb',
      estimatedWeight: 15.0,
      estimatedPrice: 3150.0,
      status: LotStatus.pending,
      createdAt: DateTime(2026, 9, 18),
    );

    final testAcceptedLot = LotEntity(
      id: 'lot_accepted_1',
      collectorId: 'col_1',
      materialName: 'battery',
      estimatedWeight: 25.0,
      estimatedPrice: 2125.0,
      status: LotStatus.accepted,
      createdAt: DateTime(2026, 9, 17),
    );

    final testCompletedLot = LotEntity(
      id: 'lot_completed_1',
      collectorId: 'col_1',
      materialName: 'plastic',
      estimatedWeight: 50.0,
      actualWeight: 50.0,
      estimatedPrice: 1100.0,
      finalPrice: 1100.0,
      status: LotStatus.completed,
      createdAt: DateTime(2026, 9, 16),
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
          child: const CollectorLotsScreen(),
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
        expect(find.text('लॉट लोड हो रहे हैं...'), findsOneWidget);
      },
    );

    testWidgets('Renders failure state with error message and retry button', (
      tester,
    ) async {
      bloc.emitState(const CollectorLotsFailure('कनेक्शन विफलता'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('लोड करने में समस्या हुई'), findsOneWidget);
      expect(find.text('कनेक्शन विफलता'), findsOneWidget);
      expect(find.text('पुनः प्रयास करें'), findsOneWidget);
    });

    testWidgets('Renders empty state when lots list is empty', (tester) async {
      bloc.emitState(
        const CollectorLotsLoaded(
          lots: [],
          currentPage: 1,
          hasReachedMax: true,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('कोई लॉट नहीं मिला'), findsOneWidget);
      expect(find.text('नया लॉट बनाएं'), findsOneWidget);
    });

    testWidgets(
      'Renders loaded lots list with filter tabs and correct badges',
      (tester) async {
        bloc.emitState(
          CollectorLotsLoaded(
            lots: [testPendingLot, testAcceptedLot, testCompletedLot],
            currentPage: 1,
            hasReachedMax: true,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Screen title
        expect(find.text('मेरे कबाड़ लॉट'), findsOneWidget);

        // Filter tabs
        expect(find.text('सभी'), findsOneWidget);
        expect(find.text('लंबित'), findsWidgets);
        expect(find.text('प्रगति पर'), findsOneWidget);
        expect(find.text('पूर्ण'), findsWidgets);

        // Lot items in "सभी" tab
        expect(find.text('15 किलो'), findsOneWidget);
        expect(find.text('25 किलो'), findsOneWidget);
        expect(find.text('50 किलो'), findsOneWidget);
      },
    );

    testWidgets('Filter tabs correctly filter lots', (tester) async {
      bloc.emitState(
        CollectorLotsLoaded(
          lots: [testPendingLot, testAcceptedLot, testCompletedLot],
          currentPage: 1,
          hasReachedMax: true,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially on 'सभी', all 3 lots shown
      expect(find.text('15 किलो'), findsOneWidget);
      expect(find.text('25 किलो'), findsOneWidget);
      expect(find.text('50 किलो'), findsOneWidget);

      // Tap 'लंबित' ChoiceChip
      await tester.tap(find.widgetWithText(ChoiceChip, 'लंबित'));
      await tester.pumpAndSettle();

      expect(find.text('15 किलो'), findsOneWidget);
      expect(find.text('25 किलो'), findsNothing);
      expect(find.text('50 किलो'), findsNothing);

      // Tap 'प्रगति पर' (accepted)
      await tester.tap(find.widgetWithText(ChoiceChip, 'प्रगति पर'));
      await tester.pumpAndSettle();

      expect(find.text('15 किलो'), findsNothing);
      expect(find.text('25 किलो'), findsOneWidget);
      expect(find.text('50 किलो'), findsNothing);

      // Tap 'पूर्ण' (completed)
      await tester.tap(find.widgetWithText(ChoiceChip, 'पूर्ण'));
      await tester.pumpAndSettle();

      expect(find.text('15 किलो'), findsNothing);
      expect(find.text('25 किलो'), findsNothing);
      expect(find.text('50 किलो'), findsOneWidget);
    });

    testWidgets('Tapping lot card navigates to /collector-lot-details', (
      tester,
    ) async {
      Map<String, dynamic>? navigatedArgs;

      bloc.emitState(
        CollectorLotsLoaded(
          lots: [testPendingLot],
          currentPage: 1,
          hasReachedMax: true,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            '/collector-lot-details': (context) {
              navigatedArgs =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              return const Scaffold(body: Text('Collector Lot Details Screen'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      final lotCard = find.text('15 किलो');
      expect(lotCard, findsOneWidget);
      await tester.tap(lotCard);
      await tester.pumpAndSettle();

      expect(find.text('Collector Lot Details Screen'), findsOneWidget);
      expect(navigatedArgs, isNotNull);
      expect(navigatedArgs!['lotId'], equals('lot_pending_1'));
    });
  });
}
