enum AppLanguage {
  hindi('hi', 'hi-IN', 'हिंदी'),
  marathi('mr', 'mr-IN', 'मराठी'),
  english('en', 'en-IN', 'English');

  final String code;
  final String ttsLocale;
  final String displayName;

  const AppLanguage(this.code, this.ttsLocale, this.displayName);

  String get nativeLabel {
    switch (this) {
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.marathi:
        return 'मराठी';
      case AppLanguage.english:
        return 'English';
    }
  }

  String get englishLabel {
    switch (this) {
      case AppLanguage.hindi:
        return 'Hindi';
      case AppLanguage.marathi:
        return 'Marathi';
      case AppLanguage.english:
        return 'English';
    }
  }

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.hindi;
    final trimmed = code.toLowerCase().trim();
    for (final lang in AppLanguage.values) {
      if (lang.code == trimmed) return lang;
    }
    return AppLanguage.hindi;
  }
}

