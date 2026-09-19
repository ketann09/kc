import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/routing/app_router.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/onboarding/role_selection_screen.dart';

class FakeAuthRepoForNavigation implements AuthRepository {
  @override
  Future<UserEntity> getCurrentUser() async {
    return const UserEntity(
      id: 'u1',
      fullName: 'User',
      phoneNumber: '9876543210',
      role: UserRole.collector,
    );
  }

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    return AuthSessionEntity(
      user: const UserEntity(
        id: 'u1',
        fullName: 'User',
        phoneNumber: '9876543210',
        role: UserRole.collector,
      ),
      accessToken: 'token',
      refreshToken: 'refresh',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshAccessToken() async => 'token';

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
    return UserEntity(
      id: 'u1',
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;
}

void main() {
  Widget buildAppWithRouter({required AuthBloc authBloc}) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        onGenerateRoute: AppRouter.generateRoute,
        home: const RoleSelectionScreen(),
      ),
    );
  }

  group('Onboarding Navigation Flow Tests', () {
    late FakeAuthRepoForNavigation repo;
    late AuthBloc authBloc;

    setUp(() {
      repo = FakeAuthRepoForNavigation();
      authBloc = AuthBloc(authRepository: repo);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets(
      'Collector flow: RoleSelection -> StateSelection -> CitySelection -> RegisterScreen',
      (tester) async {
        await tester.pumpWidget(buildAppWithRouter(authBloc: authBloc));
        await tester.pumpAndSettle();

        // 1. RoleSelectionScreen
        expect(find.text('आप कौन हैं?'), findsOneWidget);
        expect(find.text('मैं कलेक्टर हूँ'), findsOneWidget);
        expect(find.text('मैं रीसाइक्लर हूँ'), findsOneWidget);

        // Tap "मैं कलेक्टर हूँ"
        await tester.tap(find.text('मैं कलेक्टर हूँ'));
        await tester.pumpAndSettle();

        // 2. StateSelectionScreen
        expect(find.text('राज्य चुनें'), findsOneWidget);
        expect(find.text('उत्तर प्रदेश'), findsOneWidget);

        // Tap "उत्तर प्रदेश"
        await tester.tap(find.text('उत्तर प्रदेश'));
        await tester.pumpAndSettle();

        // 3. CitySelectionScreen
        expect(find.text('शहर चुनें'), findsOneWidget);
        expect(find.text('उत्तर प्रदेश में अपना शहर चुनें'), findsOneWidget);
        expect(find.text('गाज़ियाबाद'), findsOneWidget);

        // Tap "गाज़ियाबाद"
        await tester.tap(find.text('गाज़ियाबाद'));
        await tester.pumpAndSettle();

        // 4. RegisterScreen
        expect(find.text('खाता बनाएं'), findsOneWidget);
        expect(find.text('कलेक्टर खाता'), findsOneWidget);
        expect(find.text('उत्तर प्रदेश • गाज़ियाबाद'), findsOneWidget);
        expect(find.text('पूरा नाम'), findsOneWidget);
        expect(find.text('मोबाइल नंबर'), findsOneWidget);
        expect(find.text('पासवर्ड'), findsOneWidget);
        expect(find.text('पिन कोड (वैकल्पिक)'), findsOneWidget);
        expect(find.text('पंजीकरण करें'), findsOneWidget);
      },
    );

    testWidgets(
      'Recycler flow: RoleSelection -> StateSelection -> CitySelection -> RegisterScreen',
      (tester) async {
        await tester.pumpWidget(buildAppWithRouter(authBloc: authBloc));
        await tester.pumpAndSettle();

        // 1. RoleSelectionScreen
        expect(find.text('मैं रीसाइक्लर हूँ'), findsOneWidget);

        // Tap "मैं रीसाइक्लर हूँ"
        await tester.tap(find.text('मैं रीसाइक्लर हूँ'));
        await tester.pumpAndSettle();

        // 2. StateSelectionScreen
        expect(find.text('राज्य चुनें'), findsOneWidget);
        expect(find.text('महाराष्ट्र'), findsOneWidget);

        // Tap "महाराष्ट्र"
        await tester.tap(find.text('महाराष्ट्र'));
        await tester.pumpAndSettle();

        // 3. CitySelectionScreen
        expect(find.text('शहर चुनें'), findsOneWidget);
        expect(find.text('महाराष्ट्र में अपना शहर चुनें'), findsOneWidget);
        expect(find.text('मुंबई'), findsOneWidget);

        // Tap "मुंबई"
        await tester.tap(find.text('मुंबई'));
        await tester.pumpAndSettle();

        // 4. RegisterScreen
        expect(find.text('खाता बनाएं'), findsOneWidget);
        expect(find.text('रीसाइक्लर खाता'), findsOneWidget);
        expect(find.text('महाराष्ट्र • मुंबई'), findsOneWidget);
      },
    );
  });
}
