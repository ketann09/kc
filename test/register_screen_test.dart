import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/onboarding/register_screen.dart';

class FakeAuthRepositoryForScreen implements AuthRepository {
  bool failRegister = false;
  String registerErrorMessage = 'इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है';

  final collectorUser = const UserEntity(
    id: 'user_col_1',
    fullName: 'राहुल शर्मा',
    phoneNumber: '9876543210',
    role: UserRole.collector,
  );

  final recyclerUser = const UserEntity(
    id: 'user_rec_1',
    fullName: 'अमित कुमार',
    phoneNumber: '9123456789',
    role: UserRole.recycler,
  );

  @override
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    if (failRegister) {
      throw ApiException(
        message: registerErrorMessage,
        statusCode: 409,
        type: ApiExceptionType.unknown,
      );
    }
    return role == UserRole.recycler ? recyclerUser : collectorUser;
  }

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    final user = phoneNumber == '9123456789' ? recyclerUser : collectorUser;
    return AuthSessionEntity(
      user: user,
      accessToken: 'token_123',
      refreshToken: 'refresh_123',
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async => collectorUser;

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshAccessToken() async => 'token_123';

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;
}

void main() {
  void configureDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget({
    required AuthBloc authBloc,
    String role = 'collector',
    String state = 'उत्तर प्रदेश',
    String city = 'गाज़ियाबाद',
    NavigatorObserver? navigatorObserver,
  }) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
        initialRoute: '/register',
        routes: {
          '/': (_) => const Scaffold(body: Text('Login Screen')),
          '/register': (_) => RegisterScreen(
            role: role,
            state: state,
            city: city,
          ),
          '/collector-dashboard': (_) =>
              const Scaffold(body: Text('Collector Dashboard')),
          '/recycler-dashboard': (_) =>
              const Scaffold(body: Text('Recycler Dashboard')),
        },
      ),
    );
  }

  group('RegisterScreen Widget Tests', () {
    late FakeAuthRepositoryForScreen repository;
    late AuthBloc authBloc;

    setUp(() {
      repository = FakeAuthRepositoryForScreen();
      authBloc = AuthBloc(authRepository: repository);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('1. Renders title, badges, fields and buttons correctly', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(
        buildTestWidget(
          authBloc: authBloc,
          role: 'collector',
          state: 'उत्तर प्रदेश',
          city: 'गाज़ियाबाद',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('खाता बनाएं'), findsOneWidget);
      expect(find.text('कलेक्टर खाता'), findsOneWidget);
      expect(find.text('उत्तर प्रदेश • गाज़ियाबाद'), findsOneWidget);
      expect(find.text('पूरा नाम'), findsOneWidget);
      expect(find.text('मोबाइल नंबर'), findsOneWidget);
      expect(find.text('पासवर्ड'), findsOneWidget);
      expect(find.text('पिन कोड (वैकल्पिक)'), findsOneWidget);
      expect(find.text('पंजीकरण करें'), findsOneWidget);
      expect(find.text('पहले से खाता है? लॉग इन करें'), findsOneWidget);
    });

    testWidgets('2. Renders recycler badge when role is recycler', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(
        buildTestWidget(
          authBloc: authBloc,
          role: 'recycler',
          state: 'महाराष्ट्र',
          city: 'मुंबई',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('रीसाइक्लर खाता'), findsOneWidget);
      expect(find.text('महाराष्ट्र • मुंबई'), findsOneWidget);
    });

    testWidgets('3. Displays validation error when name is empty', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('पंजीकरण करें'));
      await tester.tap(find.text('पंजीकरण करें'));
      await tester.pump();

      expect(find.text('कृपया अपना पूरा नाम दर्ज करें'), findsOneWidget);
    });

    testWidgets('4. Displays validation error when phone is invalid', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextField, 'उदा. राहुल शर्मा'),
        'राहुल शर्मा',
      );
      // Enter invalid phone
      await tester.enterText(
        find.widgetWithText(TextField, '10 अंकों का नंबर'),
        '12345',
      );

      await tester.ensureVisible(find.text('पंजीकरण करें'));
      await tester.tap(find.text('पंजीकरण करें'));
      await tester.pump();

      expect(
        find.text('कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें'),
        findsOneWidget,
      );
    });

    testWidgets('5. Displays validation error when password is less than 6 chars', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'उदा. राहुल शर्मा'),
        'राहुल शर्मा',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '10 अंकों का नंबर'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'कम से कम 6 अक्षर'),
        '123',
      );

      await tester.ensureVisible(find.text('पंजीकरण करें'));
      await tester.tap(find.text('पंजीकरण करें'));
      await tester.pump();

      expect(
        find.text('पासवर्ड कम से कम 6 अक्षरों का होना चाहिए'),
        findsOneWidget,
      );
    });

    testWidgets('6. Displays validation error when pincode is not 6 digits', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'उदा. राहुल शर्मा'),
        'राहुल शर्मा',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '10 अंकों का नंबर'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'कम से कम 6 अक्षर'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '6 अंकों का पिन कोड'),
        '123',
      );

      await tester.ensureVisible(find.text('पंजीकरण करें'));
      await tester.tap(find.text('पंजीकरण करें'));
      await tester.pump();

      expect(find.text('पिन कोड 6 अंकों का होना चाहिए'), findsOneWidget);
    });

    testWidgets(
      '7. Successful collector submission auto-logins and navigates to collector dashboard',
      (tester) async {
        configureDisplay(tester);
        await tester.pumpWidget(
          buildTestWidget(
            authBloc: authBloc,
            role: 'collector',
            state: 'उत्तर प्रदेश',
            city: 'गाज़ियाबाद',
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('register_name_field')),
          'राहुल शर्मा',
        );
        await tester.enterText(
          find.byKey(const Key('register_phone_field')),
          '9876543210',
        );
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('register_pincode_field')),
          '201001',
        );

        await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
        await tester.tap(find.byKey(const Key('register_submit_button')));
        await tester.pump();
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();

        expect(find.text('Collector Dashboard'), findsOneWidget);
      },
    );

    testWidgets(
      '8. Successful recycler submission auto-logins and navigates to recycler dashboard',
      (tester) async {
        configureDisplay(tester);
        await tester.pumpWidget(
          buildTestWidget(
            authBloc: authBloc,
            role: 'recycler',
            state: 'महाराष्ट्र',
            city: 'मुंबई',
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('register_name_field')),
          'अमित कुमार',
        );
        await tester.enterText(
          find.byKey(const Key('register_phone_field')),
          '9123456789',
        );
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'password123',
        );

        await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
        await tester.tap(find.byKey(const Key('register_submit_button')));
        await tester.pump();
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();

        expect(find.text('Recycler Dashboard'), findsOneWidget);
      },
    );

    testWidgets('9. Shows error message SnackBar on registration failure', (
      tester,
    ) async {
      configureDisplay(tester);
      repository.failRegister = true;

      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'राहुल शर्मा',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'password123',
      );

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(
        find.text('इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है'),
        findsOneWidget,
      );
    });

    testWidgets('10. Link to login navigates back to root login screen', (
      tester,
    ) async {
      configureDisplay(tester);
      await tester.pumpWidget(buildTestWidget(authBloc: authBloc));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('पहले से खाता है? लॉग इन करें'));
      await tester.tap(find.text('पहले से खाता है? लॉग इन करें'));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
