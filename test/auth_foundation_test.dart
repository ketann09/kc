import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_event.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  AuthSessionEntity? sessionToRestore;

  final testUser = const UserEntity(
    id: 'user_123',
    fullName: 'Test User',
    phoneNumber: '9876543210',
    role: UserRole.collector,
  );

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (shouldFailLogin) {
      throw ApiException.unauthorized(message: 'गलत क्रेडेंशियल');
    }
    return AuthSessionEntity(
      user: testUser,
      accessToken: 'fake_access_token',
      refreshToken: 'fake_refresh_token',
    );
  }

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
    return testUser;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return testUser;
  }

  @override
  Future<String> refreshAccessToken() async {
    return 'new_fake_access_token';
  }

  @override
  Future<void> logout() async {
    sessionToRestore = null;
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    return sessionToRestore;
  }
}

void main() {
  group('AuthBloc Tests', () {
    late FakeAuthRepository fakeAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      authBloc = AuthBloc(authRepository: fakeAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    test('Emits [Authenticated] when session restoration succeeds', () async {
      final session = AuthSessionEntity(
        user: fakeAuthRepository.testUser,
        accessToken: 'valid_token',
        refreshToken: 'valid_refresh',
      );
      fakeAuthRepository.sessionToRestore = session;

      final expectedStates = [
        Authenticated(fakeAuthRepository.testUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthCheckRequested());
    });

    test('Emits [Unauthenticated] when no session exists to restore', () async {
      fakeAuthRepository.sessionToRestore = null;

      final expectedStates = [
        const Unauthenticated(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthCheckRequested());
    });

    test('Emits [AuthLoading, Authenticated] on successful login', () async {
      fakeAuthRepository.shouldFailLogin = false;

      final expectedStates = [
        const AuthLoading(),
        Authenticated(fakeAuthRepository.testUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthLoginRequested(
          phoneNumber: '9876543210',
          password: 'password123',
        ),
      );
    });

    test('Emits [AuthLoading, AuthFailure] on invalid credentials', () async {
      fakeAuthRepository.shouldFailLogin = true;

      final expectedStates = [
        const AuthLoading(),
        const AuthFailure('गलत क्रेडेंशियल'),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthLoginRequested(
          phoneNumber: '9876543210',
          password: 'wrong_password',
        ),
      );
    });

    test('Emits [AuthLoading, Unauthenticated] on logout', () async {
      final expectedStates = [
        const AuthLoading(),
        const Unauthenticated(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthLogoutRequested());
    });
  });
}
