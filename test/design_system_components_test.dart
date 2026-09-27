import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_language.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/core/widgets/app_button.dart';
import 'package:kabadiwala_connect/core/widgets/app_card.dart';
import 'package:kabadiwala_connect/core/widgets/app_empty_state.dart';
import 'package:kabadiwala_connect/core/widgets/app_stat_card.dart';
import 'package:kabadiwala_connect/core/widgets/app_status_badge.dart';
import 'package:kabadiwala_connect/core/widgets/app_stepper.dart';
import 'package:kabadiwala_connect/core/widgets/fulfillment_timeline.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';

Widget _wrapWithLocalization(Widget child, {AppLanguage language = AppLanguage.hindi}) {
  return MaterialApp(
    home: AppLocalizationsWidget(
      language: language,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Phase 6.1A — Design Tokens & Theme Tests', () {
    test('AppColors matches prototype color palette tokens', () {
      expect(AppColors.saffronPrimary, const Color(0xFFFF6B00));
      expect(AppColors.saffronDark, const Color(0xFFE05E00));
      expect(AppColors.saffron50, const Color(0xFFFFF8F2));
      expect(AppColors.saffron100, const Color(0xFFFFF4E8));
      expect(AppColors.saffron200, const Color(0xFFFFE4CC));
      expect(AppColors.greenPrimary, const Color(0xFF16A34A));
      expect(AppColors.green50, const Color(0xFFF0FDF4));
      expect(AppColors.amberPrimary, const Color(0xFFD97706));
      expect(AppColors.amber50, const Color(0xFFFFFBEB));
      expect(AppColors.redPrimary, const Color(0xFFDC2626));
      expect(AppColors.pageBackground, const Color(0xFFFFFDFB));
      expect(AppColors.white, const Color(0xFFFFFFFF));
      expect(AppColors.dark900, const Color(0xFF111827));
      expect(AppColors.dark700, const Color(0xFF374151));
      expect(AppColors.dark500, const Color(0xFF6B7280));
      expect(AppColors.border, const Color(0xFFF3F4F6));
    });

    test('AppTheme.lightTheme initializes with saffron primary and mobile defaults', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.pageBackground);
      expect(theme.colorScheme.primary, AppColors.saffronPrimary);
      expect(theme.elevatedButtonTheme.style?.minimumSize?.resolve({}), const Size.fromHeight(56));
    });
  });

  group('Phase 6.1A — AppCard Widget Tests', () {
    testWidgets('Renders default card with white background and child content', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          const AppCard(
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Renders warm card with saffron-50 background', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppCard.warm(
            child: const Text('Warm Card'),
          ),
        ),
      );

      expect(find.text('Warm Card'), findsOneWidget);
    });

    testWidgets('Renders dashed action card', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppCard.dashed(
            child: const Text('Dashed Card'),
          ),
        ),
      );

      expect(find.text('Dashed Card'), findsOneWidget);
    });

    testWidgets('Responds to tap when onTap is provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Clickable Card'),
          ),
        ),
      );

      await tester.tap(find.text('Clickable Card'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('Phase 6.1A — AppButton Widget Tests', () {
    testWidgets('Primary button enforces 56dp height and saffron styling', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppButton.primary(
            text: 'Submit Lot',
            onPressed: () {},
          ),
        ),
      );

      final buttonFinder = find.byType(AppButton);
      expect(buttonFinder, findsOneWidget);
      final size = tester.getSize(buttonFinder);
      expect(size.height, 56.0);
      expect(find.text('Submit Lot'), findsOneWidget);
    });

    testWidgets('Secondary button renders with 48dp md size', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppButton.secondary(
            text: 'View Estimate',
            onPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, 48.0);
      expect(find.text('View Estimate'), findsOneWidget);
    });

    testWidgets('Shows loading indicator and disables tap during isLoading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppButton(
            text: 'Saving',
            isLoading: true,
            loadingText: 'Saving...',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving...'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tapped, isFalse);
    });

    testWidgets('Renders left and right icons correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppButton(
            text: 'With Icons',
            leftIcon: const Icon(Icons.add),
            rightIcon: const Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('With Icons'), findsOneWidget);
    });
  });

  group('Phase 6.1A — AppStatusBadge Widget Tests', () {
    testWidgets('Combines icon, color, and localized text for lot statuses', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  AppStatusBadge.forLotStatus(context, LotStatus.pending),
                  AppStatusBadge.forLotStatus(context, LotStatus.accepted),
                  AppStatusBadge.forLotStatus(context, LotStatus.picked),
                  AppStatusBadge.forLotStatus(context, LotStatus.completed),
                ],
              );
            },
          ),
        ),
      );

      // Verify icons and localized text exist together
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      expect(find.text('लंबित'), findsOneWidget); // Hindi pending
      expect(find.text('स्वीकृत'), findsOneWidget); // Hindi accepted
      expect(find.text('रास्ते में'), findsOneWidget); // Hindi picked
      expect(find.text('पूर्ण'), findsOneWidget); // Hindi completed
    });

    testWidgets('Renders verified trust badge and best match badge', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          Column(
            children: [
              AppStatusBadge.verified(label: 'Verified Buyer'),
              AppStatusBadge.bestMatch(label: 'Best Match'),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
      expect(find.text('Verified Buyer'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
      expect(find.text('Best Match'), findsOneWidget);
    });
  });

  group('Phase 6.1A — AppEmptyState Widget Tests', () {
    testWidgets('Renders empty state with icon, title, description, and action button', (tester) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppEmptyState(
            title: 'No Scrap Lots Found',
            description: 'You have not listed any scrap lots yet.',
            actionText: 'Create Your First Lot',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('No Scrap Lots Found'), findsOneWidget);
      expect(find.text('You have not listed any scrap lots yet.'), findsOneWidget);
      expect(find.text('Create Your First Lot'), findsOneWidget);

      await tester.tap(find.text('Create Your First Lot'));
      await tester.pumpAndSettle();
      expect(actionTriggered, isTrue);
    });
  });

  group('Phase 6.1A — AppStatCard Widget Tests', () {
    testWidgets('Renders metric label, big value, icon, and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithLocalization(
          AppStatCard(
            label: 'Total Lots',
            value: '24',
            icon: Icons.inventory_2_outlined,
            accent: AppStatAccent.saffron,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Total Lots'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);

      await tester.tap(find.text('Total Lots'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('Phase 6.1A — AppStepper Widget Tests', () {
    testWidgets('Renders 3-step progress bar with completed check and active saffron step', (tester) async {
      int tappedStep = -1;
      const steps = [
        AppStepItem(number: 1, title: 'Photos & AI Scan'),
        AppStepItem(number: 2, title: 'Quantity & Location'),
        AppStepItem(number: 3, title: 'Review & Submit'),
      ];

      await tester.pumpWidget(
        _wrapWithLocalization(
          AppStepper(
            steps: steps,
            currentStep: 2,
            onStepTapped: (step) => tappedStep = step,
          ),
        ),
      );

      expect(find.text('Photos & AI Scan'), findsOneWidget);
      expect(find.text('Quantity & Location'), findsOneWidget);
      expect(find.text('Review & Submit'), findsOneWidget);

      // Step 1 is completed -> check icon rendered
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Step 2 is active -> number 2 rendered
      expect(find.text('2'), findsOneWidget);

      // Step 3 is upcoming -> number 3 rendered
      expect(find.text('3'), findsOneWidget);

      // Tap completed step 1
      await tester.tap(find.text('Photos & AI Scan'));
      await tester.pumpAndSettle();
      expect(tappedStep, 1);
    });
  });

  group('Phase 6.1A — FulfillmentTimeline Widget Tests', () {
    testWidgets('Renders vertical lifecycle stages according to lot status', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          const FulfillmentTimeline(
            status: LotStatus.picked,
          ),
          language: AppLanguage.english,
        ),
      );

      expect(find.text('Fulfillment Lifecycle'), findsOneWidget);
      expect(find.text('Lot Accepted'), findsOneWidget);
      expect(find.text('Pickup Dispatched'), findsOneWidget);
      expect(find.text('Weight Verified & Delivered'), findsOneWidget);
      expect(find.text('Completed & Recycled'), findsOneWidget);

      // Completed/active stages have check icons
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      // Upcoming stages have clock icons
      expect(find.byIcon(Icons.schedule_rounded), findsNWidgets(2));
    });

    testWidgets('Renders Hindi lifecycle vernacular titles by default', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          const FulfillmentTimeline(
            status: LotStatus.delivered,
          ),
          language: AppLanguage.hindi,
        ),
      );

      expect(find.text('ऑर्डर की स्थिति (लाइफसाइकिल)'), findsOneWidget);
      expect(find.text('लॉट स्वीकार किया गया'), findsOneWidget);
      expect(find.text('पिकअप रवाना'), findsOneWidget);
      expect(find.text('वजन सत्यापन एवं डिलीवरी'), findsOneWidget);
      expect(find.text('पुनर्चक्रण पूर्ण'), findsOneWidget);
    });
  });
}
