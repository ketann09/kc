import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/routing/app_router.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_state.dart';
import 'package:kabadiwala_connect/features/recycler/recycler_lot_details_screen.dart';

class MockRecyclerLotsRepository implements RecyclerLotsRepository {
  bool shouldFail = false;
  String errorMessage = 'लॉट उपलब्ध नहीं है';
  LotEntity? lot;

  int fetchCount = 0;
  String? lastLotId;
  int acceptCount = 0;
  String? lastAcceptedLotId;
  double? lastAcceptedPrice;

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
    fetchCount++;
    lastLotId = lotId;
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    if (lot != null) return lot!;
    throw Exception('Not found');
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async {
    acceptCount++;
    lastAcceptedLotId = lotId;
    lastAcceptedPrice = price;
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    if (lot != null) {
      return LotEntity(
        id: lot!.id,
        collectorId: lot!.collectorId,
        collectorName: lot!.collectorName,
        collectorPhone: lot!.collectorPhone,
        materialName: lot!.materialName,
        estimatedWeight: lot!.estimatedWeight,
        estimatedPrice: lot!.estimatedPrice,
        location: lot!.location,
        status: LotStatus.accepted,
        description: lot!.description,
        schedulePickup: lot!.schedulePickup,
        createdAt: lot!.createdAt,
      );
    }
    throw Exception('Not found');
  }
}

void main() {
  late MockRecyclerLotsRepository fakeRepo;
  late GetRecyclerLotDetailsUseCase useCase;
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
    createdAt: DateTime(2026, 9, 17),
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
    createdAt: DateTime(2026, 9, 17),
  );

  setUp(() {
    fakeRepo = MockRecyclerLotsRepository();
    fakeRepo.lot = sampleLot;
    useCase = GetRecyclerLotDetailsUseCase(fakeRepo);
    acceptUseCase = AcceptRecyclerLotUseCase(fakeRepo);
    bloc = RecyclerLotDetailsBloc(
      getRecyclerLotDetailsUseCase: useCase,
      acceptRecyclerLotUseCase: acceptUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildTestApp({
    RecyclerLotDetailsBloc? providedBloc,
    String lotId = 'lot-xyz-999',
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<RecyclerLotDetailsBloc>.value(
        value: providedBloc ?? bloc,
        child: RecyclerLotDetailsScreen(lotId: lotId),
      ),
    );
  }

  group('RecyclerLotDetailsScreen Widget Tests', () {
    testWidgets('1. Displays loading state with spinner and caption', (
      tester,
    ) async {
      bloc.emit(const RecyclerLotDetailsLoading());
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('लॉट विवरण लोड हो रहा है...'), findsOneWidget);
    });

    testWidgets('2. Displays loaded state with real lot data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bloc.emit(RecyclerLotDetailsLoaded(sampleLot));
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Material header
      expect(find.text('तांबा वायर'), findsOneWidget);
      expect(find.text('लॉट #lot-xyz-999'), findsOneWidget);
      expect(find.text('लंबित'), findsOneWidget);

      // Estimated price & weight
      expect(find.text('₹12500'), findsOneWidget);
      expect(find.text('25 किलो'), findsOneWidget);

      // Collector information
      expect(find.text('राहुल शर्मा'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      // Location & Handover
      expect(find.text('गाजियाबाद, उत्तर प्रदेश'), findsOneWidget);
      expect(find.text('पिकअप अनुरोध'), findsOneWidget);

      // Description
      expect(find.text('शुद्ध तांबा वायर 25 किलो'), findsOneWidget);

      // Real acceptance button is displayed for pending lot
      expect(find.text('लॉट स्वीकार करें'), findsOneWidget);
    });

    testWidgets(
      '3. Displays failure state with message and retry button triggers fetch',
      (tester) async {
        bloc.emit(
          const RecyclerLotDetailsFailure('सर्वर से संपर्क नहीं हो सका'),
        );
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('विवरण लोड करने में समस्या'), findsOneWidget);
        expect(find.text('सर्वर से संपर्क नहीं हो सका'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('पुनः प्रयास करें'));
        await tester.pump();

        expect(bloc.state, isA<RecyclerLotDetailsLoading>());
      },
    );

    testWidgets(
      '4. AppRouter routes /incoming-lot with lotId to RecyclerLotDetailsScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/incoming-lot',
                    arguments: 'lot-route-test-123',
                  );
                },
                child: const Text('Open Details'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Details'));
        await tester.pumpAndSettle();

        expect(find.byType(RecyclerLotDetailsScreen), findsOneWidget);
        final screenWidget = tester.widget<RecyclerLotDetailsScreen>(
          find.byType(RecyclerLotDetailsScreen),
        );
        expect(screenWidget.lotId, 'lot-route-test-123');
      },
    );

    testWidgets(
      '5. AppRouter routes /recycler-lot-details with lotId to RecyclerLotDetailsScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/recycler-lot-details',
                    arguments: 'lot-route-test-456',
                  );
                },
                child: const Text('Open Details'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Details'));
        await tester.pumpAndSettle();

        expect(find.byType(RecyclerLotDetailsScreen), findsOneWidget);
        final screenWidget = tester.widget<RecyclerLotDetailsScreen>(
          find.byType(RecyclerLotDetailsScreen),
        );
        expect(screenWidget.lotId, 'lot-route-test-456');
      },
    );

    testWidgets(
      '6. Tapping "लॉट स्वीकार करें" displays confirmation dialog with estimated price and confirming dispatches accept event',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bloc.emit(RecyclerLotDetailsLoaded(sampleLot));
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Verify CTA is present
        final acceptBtnFinder = find.text('लॉट स्वीकार करें');
        expect(acceptBtnFinder, findsOneWidget);

        // Tap the button
        await tester.tap(acceptBtnFinder);
        await tester.pumpAndSettle();

        // Verify confirmation dialog title and content with estimated price
        expect(find.text('लॉट स्वीकृति की पुष्टि'), findsOneWidget);
        expect(
          find.textContaining('क्या आप इस लॉट को प्रदर्शित अनुमानित मूल्य ₹12500 पर स्वीकार करना चाहते हैं?'),
          findsOneWidget,
        );

        // Tap confirm in dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'स्वीकार करें'));
        await tester.pumpAndSettle();

        // Verify bloc event was processed or state updated
        expect(fakeRepo.acceptCount, 1);
        expect(fakeRepo.lastAcceptedLotId, 'lot-xyz-999');
      },
    );

    testWidgets(
      '7. When isAccepting is true, CTA displays loading indicator and disabled state',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bloc.emit(RecyclerLotDetailsLoaded(sampleLot, isAccepting: true));
        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        expect(find.text('लॉट स्वीकार किया जा रहा है...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      },
    );

    testWidgets(
      '8. When lot status is accepted, displays verified accepted card and hides accept CTA',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final acceptedLot = acceptedSampleLot;
        bloc.emit(RecyclerLotDetailsLoaded(acceptedLot));
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Status badge
        expect(find.text('स्वीकृत'), findsOneWidget);

        // Acceptance banner
        expect(find.text('यह लॉट आपके द्वारा स्वीकार किया गया है'), findsOneWidget);
        expect(find.textContaining('कलेक्टर से संपर्क कर'), findsOneWidget);

        // Accept CTA button should not exist
        expect(find.text('लॉट स्वीकार करें'), findsNothing);
      },
    );
  });
}
