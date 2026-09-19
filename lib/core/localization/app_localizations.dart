import 'package:flutter/widgets.dart';

import 'app_language.dart';
import 'translations/app_translations.dart';
import 'translations/english_translations.dart';
import 'translations/hindi_translations.dart';
import 'translations/marathi_translations.dart';

/// Central entry point for localization in Kabadiwala Connect.
/// Provides access to translated strings with deterministic fallback cascade:
/// Marathi -> Hindi -> English.
class AppLocalizations {
  final AppLanguage language;
  final AppTranslations translations;

  AppLocalizations(this.language)
      : translations = _resolveTranslations(language);

  static final Map<AppLanguage, AppTranslations> _dictionaryMap = {
    AppLanguage.hindi: const HindiTranslations(),
    AppLanguage.marathi: const MarathiTranslations(),
    AppLanguage.english: const EnglishTranslations(),
  };

  static AppTranslations getTranslations(AppLanguage language) {
    return _dictionaryMap[language] ?? const HindiTranslations();
  }

  static AppTranslations _resolveTranslations(AppLanguage language) {
    switch (language) {
      case AppLanguage.marathi:
        return const MarathiTranslations();
      case AppLanguage.hindi:
        return const HindiTranslations();
      case AppLanguage.english:
        return const EnglishTranslations();
    }
  }

  /// Looks up the nearest [AppLocalizations] in the widget tree.
  /// Defaults to Hindi if no [AppLocalizationsWidget] ancestor is found.
  static AppLocalizations of(BuildContext context) {
    final _InheritedLocalizations? inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedLocalizations>();
    if (inherited != null) {
      return inherited.data;
    }
    return AppLocalizations(AppLanguage.hindi);
  }
}

/// Widget providing [AppLocalizations] down the widget tree.
class AppLocalizationsWidget extends StatelessWidget {
  final AppLanguage language;
  final Widget child;

  const AppLocalizationsWidget({
    super.key,
    required this.language,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _InheritedLocalizations(
      data: AppLocalizations(language),
      child: child,
    );
  }
}

class _InheritedLocalizations extends InheritedWidget {
  final AppLocalizations data;

  const _InheritedLocalizations({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedLocalizations oldWidget) {
    return data.language != oldWidget.data.language;
  }
}

/// Syntactic sugar extension for convenient context-based access.
extension AppLocalizationsX on BuildContext {
  /// Access active translated strings: `context.l10n.loginTitle`
  AppTranslations get l10n => AppLocalizations.of(this).translations;

  /// Access active app language: `context.currentLanguage`
  AppLanguage get currentLanguage => AppLocalizations.of(this).language;

  bool get isHindi => currentLanguage == AppLanguage.hindi;
  bool get isMarathi => currentLanguage == AppLanguage.marathi;
  bool get isEnglish => currentLanguage == AppLanguage.english;
}

