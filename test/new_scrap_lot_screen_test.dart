import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/ml_classification_entity.dart';
import 'package:kabadiwala_connect/domain/entities/ml_price_entity.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/classify_scrap_image_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/create_collector_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/estimate_price_usecase.dart';
import 'package:kabadiwala_connect/features/collector/new_scrap_lot_screen.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_event.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/new_lot/new_lot_state.dart';

import 'collector_bloc_test.dart';

void main() {
  group('NewScrapLotScreen Widget Tests', () {
    late FakeMLRepository fakeML;
    late FakeCollectorLotsRepository fakeLots;
    late NewLotBloc newLotBloc;

    setUp(() {
      fakeML = FakeMLRepository();
      fakeLots = FakeCollectorLotsRepository();
      newLotBloc = NewLotBloc(
        classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
        estimatePriceUseCase: EstimatePriceUseCase(fakeML),
        createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
      );
    });

    tearDown(() {
      newLotBloc.close();
    });

    Widget createWidgetUnderTest({NewLotBloc? bloc}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          '/recyclers': (context) =>
              const Scaffold(body: Text('Nearby Recyclers Screen')),
        },
        home: BlocProvider<NewLotBloc>.value(
          value: bloc ?? newLotBloc,
          child: const NewScrapLotScreen(),
        ),
      );
    }

    testWidgets('Renders all initial UI sections in Hindi-first design', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('नया कबाड़ जोड़ें'), findsOneWidget);
      expect(
        find.text('फोटो लें और AI से कबाड़ की पहचान करें'),
        findsOneWidget,
      );

      // Photo initial card
      expect(find.text('कबाड़ की फोटो लें'), findsOneWidget);
      expect(find.text('साफ़ फोटो से AI बेहतर पहचान कर पाएगा'), findsOneWidget);
      expect(find.text('कैमरा'), findsOneWidget);
      expect(find.text('गैलरी'), findsOneWidget);

      // Category chips
      expect(find.text('कबाड़ का प्रकार'), findsOneWidget);
      expect(find.text('प्लास्टिक'), findsOneWidget);
      expect(find.text('ई-वेस्ट'), findsOneWidget);
      expect(find.text('धातु / लोहा'), findsOneWidget);
      expect(find.text('कागज़'), findsOneWidget);

      // Weight section
      expect(find.text('वज़न'), findsOneWidget);
      expect(find.text('KG'), findsWidgets);
      expect(find.text('+ 1 KG'), findsOneWidget);
      expect(find.text('+ 5 KG'), findsOneWidget);

      // Price neutral state
      expect(find.text('अनुमानित कीमत'), findsOneWidget);
      expect(find.text('वज़न भरें और कीमत देखें'), findsOneWidget);

      // Primary CTA
      expect(find.text('रीसाइक्लर खोजें'), findsOneWidget);
    });

    testWidgets('Tapping category chip selects it', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap E-Waste chip
      await tester.tap(find.text('ई-वेस्ट'));
      await tester.pumpAndSettle();

      expect(newLotBloc.state.category, equals('E-Waste'));
      expect(newLotBloc.state.priceEstimate?.recommendedRateInr, equals(210.0));
      expect(newLotBloc.state.priceEstimate?.estimatedValueInr, equals(210.0));
    });

    testWidgets(
      'Displays AI classification and estimated price when populated in state',
      (tester) async {
        final populatedBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );

        // Seed state
        populatedBloc.emit(
          const NewLotState(
            status: NewLotStatus.priced,
            imagePath: 'test_path/photo.jpg',
            category: 'Plastic',
            classification: MLClassificationEntity(
              category: 'Plastic',
              confidence: 0.94,
              confidencePercent: 94.0,
            ),
            weightKg: 5.0,
            priceEstimate: MLPriceEntity(
              category: 'Plastic',
              recommendedRateInr: 25.0,
              estimatedValueInr: 125.0,
              estimatedValueMinInr: 118.0,
              estimatedValueMaxInr: 131.0,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(bloc: populatedBloc));
        await tester.pumpAndSettle();

        // AI result card
        expect(find.text('AI से पहचान'), findsOneWidget);
        expect(find.text('94% विश्वास'), findsOneWidget);

        // Price card
        expect(find.text('₹125'), findsOneWidget);
        expect(find.text('₹25 / KG'), findsOneWidget);

        // CTA button should be enabled
        final ctaFinder = find.widgetWithText(
          ElevatedButton,
          'रीसाइक्लर खोजें',
        );
        expect(ctaFinder, findsOneWidget);
        final button = tester.widget<ElevatedButton>(ctaFinder);
        expect(button.enabled, isTrue);

        populatedBloc.close();
      },
    );

    testWidgets(
      'Displays dynamic rate unit "Piece" when price estimate unit is per_piece',
      (tester) async {
        final populatedBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );

        populatedBloc.emit(
          const NewLotState(
            status: NewLotStatus.priced,
            imagePath: 'test_path/crt.jpg',
            category: 'CRT',
            classification: MLClassificationEntity(
              category: 'CRT',
              confidence: 0.98,
              confidencePercent: 98.0,
            ),
            weightKg: 10.0,
            quantity: 1,
            priceEstimate: MLPriceEntity(
              category: 'CRT',
              recommendedRateInr: 180.0,
              unit: 'per_piece',
              estimatedValueInr: 180.0,
              estimatedValueMinInr: 170.0,
              estimatedValueMaxInr: 190.0,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(bloc: populatedBloc));
        await tester.pumpAndSettle();

        expect(find.text('₹180 / Piece'), findsOneWidget);
        expect(find.text('₹180'), findsOneWidget);

        populatedBloc.close();
      },
    );

    testWidgets(
      'Tapping primary CTA dispatches NewLotSubmitted and navigates to /recyclers on success',
      (tester) async {
        String? navigatedLotId;

        final populatedBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );

        populatedBloc.emit(
          const NewLotState(
            status: NewLotStatus.priced,
            imagePath: 'test_path/photo.jpg',
            category: 'Plastic',
            weightKg: 5.0,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            routes: {
              '/recyclers': (context) {
                navigatedLotId =
                    ModalRoute.of(context)?.settings.arguments as String?;
                return const Scaffold(body: Text('Nearby Recyclers Screen'));
              },
            },
            home: BlocProvider<NewLotBloc>.value(
              value: populatedBloc,
              child: const NewScrapLotScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final ctaFinder = find.widgetWithText(
          ElevatedButton,
          'रीसाइक्लर खोजें',
        );
        expect(ctaFinder, findsOneWidget);
        await tester.tap(ctaFinder);
        await tester.pumpAndSettle();

        expect(find.text('Nearby Recyclers Screen'), findsOneWidget);
        expect(navigatedLotId, equals('lot_real_123'));

        populatedBloc.close();
      },
    );

    testWidgets(
      'Exposes prominent Retry AI Scan button when classification fails and dispatches retry',
      (tester) async {
        final failingBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );

        failingBloc.emit(
          const NewLotState(
            status: NewLotStatus.failure,
            errorType: NewLotErrorType.classification,
            imagePath: 'test_path/photo.jpg',
            errorMessage: 'Timeout error from ML service',
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(bloc: failingBloc));
        await tester.pumpAndSettle();

        // Failure banner and Retry button should be displayed
        expect(find.text('पहचान नहीं हो सकी'), findsOneWidget);
        expect(find.byKey(const Key('retry_ai_scan_button')), findsOneWidget);
        expect(find.text('पुनः AI स्कैन करें'), findsOneWidget);

        // Tapping retry button dispatches NewLotImageSelected
        final retryFinder = find.byKey(const Key('retry_ai_scan_button'));
        await tester.ensureVisible(retryFinder);
        await tester.pumpAndSettle();
        await tester.tap(retryFinder);
        await tester.pump();

        // Should transition to classifying or classified
        expect(
          failingBloc.state.status == NewLotStatus.classifying ||
              failingBloc.state.status == NewLotStatus.classified,
          isTrue,
        );

        failingBloc.close();
      },
    );

    testWidgets('Renders all 10 supported material/category chips', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final expectedCategories = [
        'प्लास्टिक',
        'ई-वेस्ट',
        'सीआरटी / टीवी मॉनिटर',
        'एलसीडी / एलईडी स्क्रीन',
        'केबल',
        'बैटरी',
        'मोटर व पुर्जे',
        'धातु / लोहा',
        'कागज़',
        'अन्य',
      ];

      for (final label in expectedCategories) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets(
      'Unit switching: selecting CRT switches input unit to Piece and quick buttons to Piece increments',
      (tester) async {
        final crtBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );
        crtBloc.emit(const NewLotState(category: 'CRT'));

        await tester.pumpWidget(createWidgetUnderTest(bloc: crtBloc));
        await tester.pumpAndSettle();

        expect(find.text('Piece'), findsWidgets);
        expect(find.text('+ 1 Piece'), findsOneWidget);
        expect(find.text('+ 5 Pieces'), findsOneWidget);
        crtBloc.close();

        final plasticBloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );
        plasticBloc.emit(const NewLotState(category: 'Plastic'));

        await tester.pumpWidget(createWidgetUnderTest(bloc: plasticBloc));
        await tester.pumpAndSettle();

        expect(find.text('KG'), findsWidgets);
        expect(find.text('+ 1 KG'), findsOneWidget);
        expect(find.text('+ 5 KG'), findsOneWidget);
        plasticBloc.close();
      },
    );

    testWidgets('Tapping an already active category chip deselects it', (
      tester,
    ) async {
      final bloc = NewLotBloc(
        classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
        estimatePriceUseCase: EstimatePriceUseCase(fakeML),
        createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
      );
      bloc.emit(const NewLotState(category: 'Plastic'));

      await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
      await tester.pumpAndSettle();
      expect(bloc.state.category, equals('Plastic'));

      // Tap plastic chip to deselect
      final plasticFinder = find.text('प्लास्टिक');
      await tester.tap(plasticFinder);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(bloc.state.category, isNull);
      bloc.close();
    });

    testWidgets(
      'AI classification overrides stale manual category selection in UI',
      (tester) async {
        final bloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );
        bloc.emit(const NewLotState(category: 'Paper'));

        await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
        await tester.pumpAndSettle();
        expect(bloc.state.category, equals('Paper'));

        // Emit new state with AI classification overriding manual category
        bloc.emit(
          const NewLotState(
            status: NewLotStatus.classified,
            imagePath: 'test_path/plastic_bottle.jpg',
            category: 'Plastic',
            classification: MLClassificationEntity(
              category: 'Plastic',
              confidence: 0.94,
              confidencePercent: 94.0,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(bloc.state.category, equals('Plastic'));
        expect(find.text('AI से पहचान'), findsOneWidget);
        bloc.close();
      },
    );

    testWidgets(
      'Manual category selection displays Selected Category and hides AI identified badge',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final bloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );
        bloc.emit(
          const NewLotState(
            status: NewLotStatus.classified,
            imagePath: 'test_path/photo.jpg',
            category: 'Plastic',
            classification: MLClassificationEntity(
              category: 'Plastic',
              confidence: 0.94,
              confidencePercent: 94.0,
            ),
            isManualCategory: false,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
        await tester.pumpAndSettle();
        expect(find.text('AI से पहचान'), findsOneWidget);

        // Tap Metal category to manually select
        final metalFinder = find.text('धातु / लोहा');
        await tester.ensureVisible(metalFinder);
        await tester.tap(metalFinder);
        await tester.pumpAndSettle();

        expect(bloc.state.isManualCategory, isTrue);
        expect(bloc.state.category, equals('Metal'));
        expect(find.text('चयनित श्रेणी'), findsOneWidget);
        expect(find.text('AI से पहचान'), findsNothing);
        bloc.close();
      },
    );

    testWidgets('CRT Piece valuation recalculates when quantity changes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = NewLotBloc(
        classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
        estimatePriceUseCase: EstimatePriceUseCase(fakeML),
        createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
      );
      bloc.emit(
        const NewLotState(
          status: NewLotStatus.priced,
          imagePath: 'test_path/crt.jpg',
          category: 'CRT',
          quantity: 1,
          weightKg: 1.0,
          priceEstimate: MLPriceEntity(
            category: 'CRT',
            recommendedRateInr: 150.0,
            unit: 'Piece',
            estimatedValueInr: 150.0,
            estimatedValueMinInr: 140.0,
            estimatedValueMaxInr: 160.0,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('₹150'), findsOneWidget);
      expect(find.text('₹150 / Piece'), findsOneWidget);

      // Tap + 1 Piece button
      final plusOneFinder = find.text('+ 1 Piece');
      expect(plusOneFinder, findsOneWidget);
      await tester.ensureVisible(plusOneFinder);
      await tester.tap(plusOneFinder);
      await tester.pumpAndSettle();

      expect(bloc.state.quantity, equals(2));
      expect(find.text('₹300'), findsOneWidget);
      bloc.close();
    });

    testWidgets('Manual category selection immediately updates rate and valuation in UI from initial state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = NewLotBloc(
        classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
        estimatePriceUseCase: EstimatePriceUseCase(fakeML),
        createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
      );

      // Select Plastic manually
      bloc.add(const NewLotCategoryChanged(category: 'Plastic', isManual: true));

      await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('₹25 / KG'), findsOneWidget);
      expect(find.text('₹25'), findsOneWidget);
      expect(bloc.state.category, equals('Plastic'));
      expect(bloc.state.isManualCategory, isTrue);

      // Switch to E-Waste
      bloc.add(const NewLotCategoryChanged(category: 'E-Waste', isManual: true));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('₹210 / KG'), findsOneWidget);
      expect(find.text('₹210'), findsOneWidget);
      expect(bloc.state.category, equals('E-Waste'));

      // Switch to CRT -> Piece unit and rate
      bloc.add(const NewLotCategoryChanged(category: 'CRT', isManual: true));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('₹150 / Piece'), findsOneWidget);
      expect(find.text('₹150'), findsOneWidget);
      expect(bloc.state.category, equals('CRT'));

      // Deselect category
      bloc.add(const NewLotCategoryChanged(category: null, isManual: false));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(bloc.state.category, isNull);
      expect(bloc.state.priceEstimate, isNull);
      expect(find.text('वज़न भरें और कीमत देखें'), findsOneWidget);

      bloc.close();
    });

    testWidgets(
      'Recycler Khoje CTA is enabled for valid manual lot without image and dispatches NewLotSubmitted',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final bloc = NewLotBloc(
          classifyScrapImageUseCase: ClassifyScrapImageUseCase(fakeML),
          estimatePriceUseCase: EstimatePriceUseCase(fakeML),
          createCollectorLotUseCase: CreateCollectorLotUseCase(fakeLots),
        );

        await tester.pumpWidget(createWidgetUnderTest(bloc: bloc));
        await tester.pumpAndSettle();

        // Initially without category, CTA should be disabled
        final ctaFinder = find.widgetWithText(ElevatedButton, 'रीसाइक्लर खोजें');
        expect(ctaFinder, findsOneWidget);
        var ctaButton = tester.widget<ElevatedButton>(ctaFinder);
        expect(ctaButton.onPressed, isNull);

        // Tap Plastic chip to manually select category
        await tester.tap(find.text('प्लास्टिक'));
        await tester.pumpAndSettle();

        expect(bloc.state.category, equals('Plastic'));
        expect(bloc.state.imagePath, isNull);

        // Now CTA should be enabled
        ctaButton = tester.widget<ElevatedButton>(ctaFinder);
        expect(ctaButton.onPressed, isNotNull);

        // Tap the CTA button
        await tester.tap(ctaFinder);
        await tester.pumpAndSettle();

        expect(bloc.state.status, equals(NewLotStatus.success));
        expect(bloc.state.createdLot?.id, equals('lot_real_123'));
        expect(find.text('Nearby Recyclers Screen'), findsOneWidget);

        bloc.close();
      },
    );
  });
}
