import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_event.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_state.dart';

class MockRegistrationAuthRepository implements AuthRepository {
  bool failRegister = false;
  String registerErrorMessage =
      'User with this phone number or email already exists';
  bool failLogin = false;
  String loginErrorMessage = 'Login failed';

  int registerCallCount = 0;
  int loginCallCount = 0;

  final testUser = const UserEntity(
    id: 'user_reg_123',
    fullName: 'राहुल शर्मा',
    phoneNumber: '9876543210',
    role: UserRole.collector,
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
    registerCallCount++;
    if (failRegister) {
      throw ApiException(
        message: registerErrorMessage,
        statusCode: 409,
        type: ApiExceptionType.unknown,
      );
    }
    return testUser;
  }

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    loginCallCount++;
    if (failLogin) {
      throw ApiException(
        message: loginErrorMessage,
        statusCode: 500,
        type: ApiExceptionType.server,
      );
    }
    return AuthSessionEntity(
      user: testUser,
      accessToken: 'fake_jwt_token',
      refreshToken: 'fake_refresh_token',
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async => testUser;

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshAccessToken() async => 'new_fake_jwt_token';

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;
}

void main() {
  group('AuthBloc Registration & Auto-login Tests', () {
    late MockRegistrationAuthRepository repository;
    late AuthBloc authBloc;

    setUp(() {
      repository = MockRegistrationAuthRepository();
      authBloc = AuthBloc(authRepository: repository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('Emits [AuthLoading, Authenticated] when registration and auto-login succeed', () async {
      repository.failRegister = false;
      repository.failLogin = false;

      final expectedStates = [
        const AuthLoading(),
        Authenticated(repository.testUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthRegisterRequested(
          fullName: 'राहुल शर्मा',
          phoneNumber: '9876543210',
          password: 'password123',
          role: UserRole.collector,
          address: UserAddressEntity(state: 'उत्तर प्रदेश', city: 'गाज़ियाबाद'),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(repository.registerCallCount, equals(1));
      expect(repository.loginCallCount, equals(1));
    });

    test('Emits [AuthLoading, AuthFailure] mapped to Hindi when phone already exists (409)', () async {
      repository.failRegister = true;
      repository.registerErrorMessage =
          'User with this phone number or email already exists';

      final expectedStates = [
        const AuthLoading(),
        const AuthFailure('इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है'),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthRegisterRequested(
          fullName: 'राहुल शर्मा',
          phoneNumber: '9876543210',
          password: 'password123',
          role: UserRole.collector,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(repository.registerCallCount, equals(1));
      expect(repository.loginCallCount, equals(0));
    });

    test('Emits planned Hindi fallback when registration succeeds but auto-login fails, without re-registering', () async {
      repository.failRegister = false;
      repository.failLogin = true;

      final expectedStates = [
        const AuthLoading(),
        const AuthFailure(
          'खाता बन गया है, कृपया मोबाइल नंबर और पासवर्ड से लॉग इन करें',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthRegisterRequested(
          fullName: 'राहुल शर्मा',
          phoneNumber: '9876543210',
          password: 'password123',
          role: UserRole.collector,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(repository.registerCallCount, equals(1));
      expect(repository.loginCallCount, equals(1));
    });
  });
}
