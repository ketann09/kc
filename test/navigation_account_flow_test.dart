import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/services/connectivity_service.dart';
import 'package:kabadiwala_connect/core/widgets/app_navigation_drawer.dart';
import 'package:kabadiwala_connect/core/widgets/change_password_sheet.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_state.dart';
import 'package:kabadiwala_connect/features/onboarding/mobile_screen.dart';
import 'package:kabadiwala_connect/features/onboarding/role_selection_screen.dart';

class MockAuthRepoForNavTest implements AuthRepository {
  String? lastOldPassword;
  String? lastNewPassword;
  bool shouldFailChangePassword = false;
  int logoutCallCount = 0;

  final user = const UserEntity(
    id: 'test_user_id',
    fullName: 'राहुल शर्मा',
    phoneNumber: '9876543210',
    role: UserRole.collector,
    address: UserAddressEntity(city: 'इन्दौर'),
  );

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (shouldFailChangePassword) {
      throw const ApiException(
        message: 'गलत वर्तमान पासवर्ड',
        type: ApiExceptionType.server,
      );
    }
    lastOldPassword = oldPassword;
    lastNewPassword = newPassword;
  }

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    return AuthSessionEntity(
      user: user,
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<UserEntity> getCurrentUser() async => user;

  @override
  Future<String> refreshAccessToken() async => 'test_access_token';

  @override
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async => user;

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;
}

class FakeConnectivityOnline implements ConnectivityService {
  @override
  bool get isOnline => true;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(true);

  @override
  Future<bool> checkConnection() async => true;

  @override
  void recordTelemetry({required bool isSuccess, ApiException? exception}) {}

  @override
  void dispose() {}
}

void main() {
  late MockAuthRepoForNavTest fakeRepo;
  late AuthBloc authBloc;

  setUp(() {
    fakeRepo = MockAuthRepoForNavTest();
    authBloc = AuthBloc(authRepository: fakeRepo);
  });

  tearDown(() {
    authBloc.close();
  });

  void configureLargeDisplay(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Phase C: Registration as Entry Point', () {
    testWidgets('MobileScreen shows create account button and login form', (tester) async {
      configureLargeDisplay(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MobileScreen(),
          ),
          routes: {
            '/role': (context) => const Scaffold(body: Text('Role Screen Mock')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Check create account button
      final createAccountBtn = find.byType(TextButton);
      expect(createAccountBtn, findsOneWidget);

      // Check login form is also available
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('लॉग इन करें'), findsNWidgets(2));

      // Tapping create account navigates to /role
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();
      expect(find.text('Role Screen Mock'), findsOneWidget);
    });

    testWidgets('RoleSelectionScreen displays role selection cards and navigates to register', (tester) async {
      configureLargeDisplay(tester);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/role',
          routes: {
            '/state': (context) => const Scaffold(body: Text('State Screen Mock')),
            '/role': (context) => BlocProvider<AuthBloc>.value(
                  value: authBloc,
                  child: const RoleSelectionScreen(),
                ),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('मैं कलेक्टर हूँ'), findsOneWidget);
      expect(find.text('मैं रीसाइक्लर हूँ'), findsOneWidget);

      await tester.tap(find.text('मैं कलेक्टर हूँ'));
      await tester.pumpAndSettle();
      expect(find.text('State Screen Mock'), findsOneWidget);
    });
  });

  group('Phase C: Navigation Menu & Drawer Flow', () {
    testWidgets('AppNavigationDrawer displays user info, role, city, and navigation options', (tester) async {
      configureLargeDisplay(tester);

      authBloc.emit(
        Authenticated(fakeRepo.user),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RepositoryProvider<AuthRepository>.value(
            value: fakeRepo,
            child: BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: Scaffold(
                drawer: const AppNavigationDrawer(),
                body: Builder(
                  builder: (ctx) => Center(
                    child: ElevatedButton(
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify profile and details
      expect(find.text('राहुल शर्मा'), findsOneWidget);
      expect(find.text('कलेक्टर'), findsOneWidget);
      expect(find.text('इन्दौर'), findsOneWidget);

      // Verify all navigation tiles exist
      expect(find.byKey(const Key('drawer_dashboard_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_lots_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_transactions_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_new_lot_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_language_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_change_password_item')), findsOneWidget);
      expect(find.byKey(const Key('drawer_logout_item')), findsOneWidget);
    });

    testWidgets('Logout tile shows confirmation dialog and dispatches logout upon confirm', (tester) async {
      configureLargeDisplay(tester);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/dashboard',
          routes: {
            '/': (context) => const Scaffold(body: Text('Login Screen Mock')),
            '/dashboard': (context) => RepositoryProvider<AuthRepository>.value(
                  value: fakeRepo,
                  child: BlocProvider<AuthBloc>.value(
                    value: authBloc,
                    child: Scaffold(
                      drawer: const AppNavigationDrawer(),
                      body: Builder(
                        builder: (ctx) => Center(
                          child: ElevatedButton(
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                            child: const Text('Open'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          },
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.byKey(const Key('drawer_logout_item')));
      await tester.pumpAndSettle();

      // Confirmation dialog should be displayed
      expect(find.byKey(const Key('confirm_logout_dialog')), findsOneWidget);
      expect(find.text('लॉग आउट की पुष्टि करें'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.byKey(const Key('confirm_logout_button')));
      await tester.pumpAndSettle();

      // Should have triggered logout on repo
      expect(fakeRepo.logoutCallCount, equals(1));
    });
  });

  group('Phase C: Change Password Flow', () {
    testWidgets('ChangePasswordSheet validates inputs, prevents mismatch, and submits valid password', (tester) async {
      configureLargeDisplay(tester);

      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: fakeRepo,
          child: RepositoryProvider<ConnectivityService>.value(
            value: FakeConnectivityOnline(),
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => Center(
                    child: ElevatedButton(
                      onPressed: () => ChangePasswordSheet.show(ctx),
                      child: const Text('Change Password'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Check fields exist
      expect(find.byKey(const Key('old_password_field')), findsOneWidget);
      expect(find.byKey(const Key('new_password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
      expect(find.byKey(const Key('change_password_submit_button')), findsOneWidget);

      // Try submitting empty -> form validation shows error
      await tester.tap(find.byKey(const Key('change_password_submit_button')));
      await tester.pumpAndSettle();
      expect(find.text('कृपया मौजूदा पासवर्ड दर्ज करें'), findsOneWidget);

      // Enter mismatched passwords
      await tester.enterText(find.byKey(const Key('old_password_field')), 'OldPass123');
      await tester.enterText(find.byKey(const Key('new_password_field')), 'NewPass123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'DifferentPass123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_password_submit_button')));
      await tester.pumpAndSettle();
      expect(find.text('नया पासवर्ड मेल नहीं खाता'), findsOneWidget);

      // Enter matching passwords
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'NewPass123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_password_submit_button')));
      await tester.pumpAndSettle();

      // Check repo received change request
      expect(fakeRepo.lastOldPassword, equals('OldPass123'));
      expect(fakeRepo.lastNewPassword, equals('NewPass123'));
    });
  });
}
