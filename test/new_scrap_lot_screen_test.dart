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
      expect(find.text('KG'), findsOneWidget);
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
  });
}
