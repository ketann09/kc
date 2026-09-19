import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_language.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/translations/english_translations.dart';
import 'package:kabadiwala_connect/core/localization/translations/hindi_translations.dart';
import 'package:kabadiwala_connect/core/localization/translations/marathi_translations.dart';

void main() {
  group('AppLanguage Enum Tests', () {
    test('AppLanguage.fromCode parses codes correctly', () {
      expect(AppLanguage.fromCode('hi'), equals(AppLanguage.hindi));
      expect(AppLanguage.fromCode('mr'), equals(AppLanguage.marathi));
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.english));
      expect(AppLanguage.fromCode('HI'), equals(AppLanguage.hindi));
      expect(AppLanguage.fromCode('mr-IN'), equals(AppLanguage.hindi)); // Unknown defaults to Hindi
      expect(AppLanguage.fromCode(null), equals(AppLanguage.hindi));
      expect(AppLanguage.fromCode('unknown'), equals(AppLanguage.hindi));
    });

    test('AppLanguage exposes correct locale and display labels', () {
      expect(AppLanguage.hindi.code, equals('hi'));
      expect(AppLanguage.hindi.ttsLocale, equals('hi-IN'));
      expect(AppLanguage.hindi.nativeLabel, equals('हिन्दी'));
      expect(AppLanguage.hindi.englishLabel, equals('Hindi'));

      expect(AppLanguage.marathi.code, equals('mr'));
      expect(AppLanguage.marathi.ttsLocale, equals('mr-IN'));
      expect(AppLanguage.marathi.nativeLabel, equals('मराठी'));
      expect(AppLanguage.marathi.englishLabel, equals('Marathi'));

      expect(AppLanguage.english.code, equals('en'));
      expect(AppLanguage.english.ttsLocale, equals('en-IN'));
      expect(AppLanguage.english.nativeLabel, equals('English'));
      expect(AppLanguage.english.englishLabel, equals('English'));
    });
  });

  group('AppLocalizations & Translations Resolution Tests', () {
    test('getTranslations resolves correct concrete classes', () {
      expect(
        AppLocalizations.getTranslations(AppLanguage.hindi),
        isA<HindiTranslations>(),
      );
      expect(
        AppLocalizations.getTranslations(AppLanguage.marathi),
        isA<MarathiTranslations>(),
      );
      expect(
        AppLocalizations.getTranslations(AppLanguage.english),
        isA<EnglishTranslations>(),
      );
    });

    test('HindiTranslations provides non-empty canonical strings', () {
      final hindi = const HindiTranslations();
      expect(hindi.loginTitle, equals('लॉग इन करें'));
      expect(hindi.collectorGreeting, equals('नमस्ते, कबाड़ी साथी'));
      expect(hindi.recyclerDashboardTitle, equals('नए लॉट अनुरोध'));
      expect(hindi.newScrapLotAction, equals('नया कबाड़ लॉट बनाएं'));
      expect(hindi.categoryPlastic, equals('प्लास्टिक'));
      expect(hindi.categoryEwaste, equals('ई-वेस्ट'));
      expect(hindi.categoryMetal, equals('धातु / लोहा'));
    });

    test('MarathiTranslations provides natural vernacular strings with Hindi fallback', () {
      final marathi = const MarathiTranslations();
      expect(marathi.loginTitle, equals('लॉग इन करा'));
      expect(marathi.collectorGreeting, equals('नमस्कार, कबाडी मित्र'));
      expect(marathi.recyclerDashboardTitle, equals('नवीन लॉट विनंत्या'));
      expect(marathi.categoryPlastic, equals('प्लॅस्टिक'));
      expect(marathi.categoryEwaste, equals('ई-कचरा'));
      expect(marathi.categoryMetal, equals('धातू / लोखंड'));
    });

    test('EnglishTranslations provides clear English strings with Hindi fallback', () {
      final english = const EnglishTranslations();
      expect(english.loginTitle, equals('Log In'));
      expect(english.collectorGreeting, equals('Hello, Collector Partner'));
      expect(english.recyclerDashboardTitle, equals('Incoming Lot Requests'));
      expect(english.categoryPlastic, equals('Plastic'));
      expect(english.categoryEwaste, equals('E-Waste'));
      expect(english.categoryMetal, equals('Metal / Iron'));
    });

    testWidgets('AppLocalizationsWidget propagates language via context extensions', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: AppLocalizationsWidget(
            language: AppLanguage.marathi,
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Scaffold(body: Text(context.l10n.loginTitle));
              },
            ),
          ),
        ),
      );

      expect(capturedContext.currentLanguage, equals(AppLanguage.marathi));
      expect(capturedContext.isMarathi, isTrue);
      expect(capturedContext.isHindi, isFalse);
      expect(capturedContext.isEnglish, isFalse);
      expect(find.text('लॉग इन करा'), findsOneWidget);
    });

    testWidgets('AppLocalizations.of defaults to Hindi if no ancestor found', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.currentLanguage, equals(AppLanguage.hindi));
      expect(capturedContext.isHindi, isTrue);
      expect(capturedContext.l10n.loginTitle, equals('लॉग इन करें'));
    });
  });
}
