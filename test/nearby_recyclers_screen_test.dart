import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/domain/entities/matched_recycler_entity.dart';
import 'package:kabadiwala_connect/domain/entities/matchmaking_result_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/matchmaking_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/collector/get_matched_recyclers_usecase.dart';
import 'package:kabadiwala_connect/features/collector/nearby_recyclers_screen.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/matchmaking/matchmaking_bloc.dart';
import 'package:kabadiwala_connect/features/collector/presentation/bloc/matchmaking/matchmaking_state.dart';

class FakeTestMatchmakingRepository implements MatchmakingRepository {
  bool shouldFail = false;
  bool returnEmpty = false;

  final testRecycler1 = const MatchedRecyclerEntity(
    recyclerId: 'rec_001',
    recyclerName: 'Green Tech Recyclers',
    price: 30.0,
    estimatedTotal: 300.0,
    distance: 2.5,
    score: 0.95,
    address: 'Industrial Area, Phase 1',
  );

  final testRecycler2 = const MatchedRecyclerEntity(
    recyclerId: 'rec_002',
    recyclerName: 'City Scrap Processors',
    price: 28.0,
    estimatedTotal: 280.0,
    distance: 4.8,
    score: 0.85,
    address: 'Sector 62',
  );

  @override
  Future<MatchmakingResultEntity> findRecyclersForLot(String lotId) async {
    if (shouldFail) {
      throw Exception('Server matchmaking failed');
    }
    if (returnEmpty) {
      return MatchmakingResultEntity(
        lotId: lotId,
        matches: const [],
        bestMatch: null,
      );
    }
    return MatchmakingResultEntity(
      lotId: lotId,
      matches: [testRecycler1, testRecycler2],
      bestMatch: testRecycler1,
    );
  }

  @override
  Future<MatchmakingResultEntity> autoMatchLot(String lotId) async {
    return findRecyclersForLot(lotId);
  }
}

void main() {
  group('NearbyRecyclersScreen Widget Tests', () {
    late FakeTestMatchmakingRepository fakeRepo;
    late MatchmakingBloc matchmakingBloc;

    setUp(() {
      fakeRepo = FakeTestMatchmakingRepository();
      matchmakingBloc = MatchmakingBloc(
        getMatchedRecyclersUseCase: GetMatchedRecyclersUseCase(fakeRepo),
      );
    });

    tearDown(() {
      matchmakingBloc.close();
    });

    Widget createWidgetUnderTest({
      String? lotId = 'lot_test_123',
      MatchmakingBloc? bloc,
      Map<String, WidgetBuilder>? routes,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        routes: routes ?? {},
        home: BlocProvider<MatchmakingBloc>.value(
          value: bloc ?? matchmakingBloc,
          child: NearbyRecyclersScreen(lotId: lotId),
        ),
      );
    }

    testWidgets('Renders missing lot ID state when lotId is null or empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(lotId: null));
      await tester.pumpAndSettle();

      expect(find.text('लॉट आईडी नहीं मिली'), findsOneWidget);
      expect(
        find.text(
          'रीसाइक्लर खोजने के लिए लॉट आईडी आवश्यक है। कृपया पहले लॉट बनाएं।',
        ),
        findsOneWidget,
      );
      expect(find.text('वापस जाएं'), findsOneWidget);
    });

    testWidgets('Renders loading state with indicator and Hindi copy', (
      tester,
    ) async {
      matchmakingBloc.emit(const MatchmakingLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('रीसाइक्लर खोजे जा रहे हैं...'), findsOneWidget);
      expect(
        find.text(
          'आपके लॉट के लिए निकटतम और सबसे अच्छे रीसाइक्लर ढूंढे जा रहे हैं',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders failure state with error message and retry button', (
      tester,
    ) async {
      matchmakingBloc.emit(
        const MatchmakingFailure(
          lotId: 'lot_test_123',
          message: 'Connection timed out',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('रीसाइक्लर लोड करने में समस्या'), findsOneWidget);
      expect(find.text('Connection timed out'), findsOneWidget);
      expect(find.text('पुनः प्रयास करें'), findsOneWidget);

      // Tap retry button and verify event is dispatched
      await tester.tap(find.text('पुनः प्रयास करें'));
      await tester.pump();

      expect(matchmakingBloc.state, isA<MatchmakingLoading>());
    });

    testWidgets('Renders empty state when no recyclers found nearby', (
      tester,
    ) async {
      matchmakingBloc.emit(
        const MatchmakingEmpty(
          lotId: 'lot_test_123',
          message: 'No recyclers available',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('कोई रीसाइक्लर नहीं मिला'), findsOneWidget);
      expect(
        find.text(
          'आपके क्षेत्र में फिलहाल कोई सक्रिय रीसाइक्लर उपलब्ध नहीं है। कृपया कुछ समय बाद पुनः प्रयास करें।',
        ),
        findsOneWidget,
      );
      expect(find.text('पुनः प्रयास करें'), findsOneWidget);
    });

    testWidgets(
      'Renders loaded state with real recyclers, best match badge, and rates',
      (tester) async {
        matchmakingBloc.emit(
          MatchmakingLoaded(
            lotId: 'lot_test_123',
            matches: [fakeRepo.testRecycler1, fakeRepo.testRecycler2],
            bestMatch: fakeRepo.testRecycler1,
            selectedRecycler: fakeRepo.testRecycler1,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Header
        expect(find.text('पास के रीसाइक्लर'), findsWidgets);
        expect(
          find.text('2 रीसाइक्लर आपके कबाड़ के लिए उपलब्ध हैं'),
          findsOneWidget,
        );

        // Recycler 1 (Best Match)
        expect(find.text('Green Tech Recyclers'), findsOneWidget);
        expect(find.text('Industrial Area, Phase 1'), findsOneWidget);
        expect(find.text('2.5 किमी दूर'), findsOneWidget);
        expect(find.text('सर्वश्रेष्ठ मैच'), findsOneWidget);
        expect(find.text('₹30'), findsOneWidget);
        expect(find.text('₹300'), findsOneWidget);
        expect(find.text('चयनित'), findsOneWidget);

        // Recycler 2
        expect(find.text('City Scrap Processors'), findsOneWidget);
        expect(find.text('Sector 62'), findsOneWidget);
        expect(find.text('4.8 किमी दूर'), findsOneWidget);
        expect(find.text('मैच: 85%'), findsOneWidget);
        expect(find.text('₹28'), findsOneWidget);
        expect(find.text('₹280'), findsOneWidget);
        expect(find.text('रीसाइक्लर चुनें'), findsOneWidget);
      },
    );

    testWidgets('Tapping unselected recycler updates selectedRecycler', (
      tester,
    ) async {
      matchmakingBloc.emit(
        MatchmakingLoaded(
          lotId: 'lot_test_123',
          matches: [fakeRepo.testRecycler1, fakeRepo.testRecycler2],
          bestMatch: fakeRepo.testRecycler1,
          selectedRecycler: fakeRepo.testRecycler1,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(matchmakingBloc.state, isA<MatchmakingLoaded>());
      expect(
        (matchmakingBloc.state as MatchmakingLoaded)
            .selectedRecycler
            ?.recyclerId,
        equals('rec_001'),
      );

      // Scroll to make sure 'रीसाइक्लर चुनें' for Recycler 2 is visible
      await tester.ensureVisible(find.text('रीसाइक्लर चुनें'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('रीसाइक्लर चुनें'));
      await tester.pumpAndSettle();

      expect(
        (matchmakingBloc.state as MatchmakingLoaded)
            .selectedRecycler
            ?.recyclerId,
        equals('rec_002'),
      );
    });

    testWidgets(
      'Tapping bottom action button opens confirmation dialog and confirms to /collector-lot-details',
      (tester) async {
        Map<String, dynamic>? navigatedArgs;

        matchmakingBloc.emit(
          MatchmakingLoaded(
            lotId: 'lot_test_123',
            matches: [fakeRepo.testRecycler1],
            bestMatch: fakeRepo.testRecycler1,
            selectedRecycler: fakeRepo.testRecycler1,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            routes: {
              '/collector-lot-details': (context) {
                navigatedArgs =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return const Scaffold(
                  body: Text('Collector Lot Details Target'),
                );
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        final confirmBtn = find.text(
          'ऑफर की पुष्टि करें (Green Tech Recyclers)',
        );
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Confirmation dialog appears
        expect(find.text('रीसाइक्लर की पुष्टि करें'), findsOneWidget);
        expect(
          find.text(
            'क्या आप Green Tech Recyclers को यह लॉट सौंपने का अनुरोध भेजना चाहते हैं?',
          ),
          findsOneWidget,
        );
        expect(find.text('₹300'), findsWidgets);

        // Tap confirm in dialog
        final dialogConfirmBtn = find.widgetWithText(
          ElevatedButton,
          'पुष्टि करें',
        );
        expect(dialogConfirmBtn, findsOneWidget);
        await tester.tap(dialogConfirmBtn);
        await tester.pumpAndSettle();

        expect(find.text('Collector Lot Details Target'), findsOneWidget);
        expect(navigatedArgs, isNotNull);
        expect(navigatedArgs!['lotId'], equals('lot_test_123'));
        expect(
          find.text('रीसाइक्लर को अनुरोध भेज दिया गया है!'),
          findsOneWidget,
        );
      },
    );
  });
}
