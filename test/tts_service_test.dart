import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kabadiwala_connect/core/services/tts_service.dart';

class FakeFlutterTts extends FlutterTts {
  bool initCalled = false;
  bool stopCalled = false;
  String? lastSpokenText;
  String? lastLanguage;
  List<String> callLog = [];
  Map<String, bool> availableLanguages = {
    'hi-IN': true,
    'mr-IN': true,
    'en-IN': true,
  };

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    callLog.add('setSpeechRate($rate)');
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    callLog.add('setVolume($volume)');
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    callLog.add('setPitch($pitch)');
  }

  @override
  void setStartHandler(void Function() callback) {
    callLog.add('setStartHandler');
  }

  @override
  void setCompletionHandler(void Function() callback) {
    callLog.add('setCompletionHandler');
  }

  @override
  void setCancelHandler(void Function() callback) {
    callLog.add('setCancelHandler');
  }

  @override
  void setErrorHandler(void Function(dynamic) callback) {
    callLog.add('setErrorHandler');
  }

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    callLog.add('isLanguageAvailable($language)');
    return availableLanguages[language] == true ? 1 : 0;
  }

  @override
  Future<dynamic> stop() async {
    stopCalled = true;
    callLog.add('stop');
    return 1;
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    lastLanguage = language;
    callLog.add('setLanguage($language)');
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
    callLog.add('speak($text)');
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterTtsServiceImpl Tests', () {
    late FakeFlutterTts fakeFlutterTts;
    late FlutterTtsServiceImpl service;

    setUp(() {
      fakeFlutterTts = FakeFlutterTts();
      service = FlutterTtsServiceImpl(flutterTts: fakeFlutterTts);
    });

    test('init configures speech rate, volume, pitch and handlers', () async {
      await service.init();

      expect(fakeFlutterTts.callLog, contains('setSpeechRate(0.48)'));
      expect(fakeFlutterTts.callLog, contains('setVolume(1.0)'));
      expect(fakeFlutterTts.callLog, contains('setPitch(1.0)'));
      expect(fakeFlutterTts.callLog, contains('setStartHandler'));
      expect(fakeFlutterTts.callLog, contains('setCompletionHandler'));
    });

    test('speak performs preemption by calling stop before speak', () async {
      await service.speak('नमस्ते कबाड़ी साथी', languageCode: 'hi-IN');

      expect(fakeFlutterTts.stopCalled, isTrue);
      expect(fakeFlutterTts.lastSpokenText, equals('नमस्ते कबाड़ी साथी'));
      expect(fakeFlutterTts.lastLanguage, equals('hi-IN'));

      final stopIndex = fakeFlutterTts.callLog.indexOf('stop');
      final speakIndex = fakeFlutterTts.callLog.indexOf('speak(नमस्ते कबाड़ी साथी)');
      expect(stopIndex, isNonNegative);
      expect(speakIndex, greaterThan(stopIndex));
    });

    test('speak resolves mr-IN directly when Marathi voice is available', () async {
      fakeFlutterTts.availableLanguages['mr-IN'] = true;

      await service.speak('नमस्कार', languageCode: 'mr-IN');

      expect(fakeFlutterTts.lastLanguage, equals('mr-IN'));
      expect(fakeFlutterTts.lastSpokenText, equals('नमस्कार'));
    });

    test('speak falls back to hi-IN when Marathi voice is not available', () async {
      fakeFlutterTts.availableLanguages['mr-IN'] = false;
      fakeFlutterTts.availableLanguages['hi-IN'] = true;

      await service.speak('नमस्कार', languageCode: 'mr-IN');

      expect(fakeFlutterTts.lastLanguage, equals('hi-IN'));
    });

    test('speak falls back to en-IN when both Marathi and Hindi voices are unavailable', () async {
      fakeFlutterTts.availableLanguages['mr-IN'] = false;
      fakeFlutterTts.availableLanguages['hi-IN'] = false;

      await service.speak('नमस्कार', languageCode: 'mr-IN');

      expect(fakeFlutterTts.lastLanguage, equals('en-IN'));
    });

    test('speak ignores empty or whitespace text silently', () async {
      await service.speak('');
      await service.speak('   ');

      expect(fakeFlutterTts.lastSpokenText, isNull);
    });

    test('stop cancels speech successfully', () async {
      await service.stop();
      expect(fakeFlutterTts.stopCalled, isTrue);
    });
  });
}
