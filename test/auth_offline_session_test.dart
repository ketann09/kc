import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/network/api_client.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/storage/auth_token_storage.dart';
import 'package:kabadiwala_connect/data/datasources/remote/auth_remote_data_source.dart';
import 'package:kabadiwala_connect/data/models/auth_response_model.dart';
import 'package:kabadiwala_connect/data/models/user_model.dart';
import 'package:kabadiwala_connect/data/repositories/auth_repository_impl.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? userToReturn;
  ApiException? errorToThrow;
  bool refreshShouldSucceed = false;

  @override
  Future<UserModel> getCurrentUser() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (userToReturn != null) {
      return userToReturn!;
    }
    throw ApiException.unknown(message: 'No user configured');
  }

  @override
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    return AuthResponseModel(
      accessToken: 'access_login',
      refreshToken: 'refresh_login',
      user:
          userToReturn ??
          UserModel.fromEntity(
            const UserEntity(
              id: 'user_login',
              fullName: 'Logged In User',
              phoneNumber: '9876543210',
              role: UserRole.collector,
            ),
          ),
    );
  }

  @override
  Future<Map<String, String>> refreshAccessToken(String refreshToken) async {
    if (refreshShouldSucceed) {
      return {
        'accessToken': 'new_access_token',
        'refreshToken': 'new_refresh_token',
      };
    }
    throw ApiException.unauthorized(message: 'Refresh token expired');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stage 5.9B: Storage & Session Resilience Tests', () {
    late SharedPreferencesAuthTokenStorage tokenStorage;
    late MockAuthRemoteDataSource mockRemoteDataSource;
    late ApiClient apiClient;
    late AuthRepositoryImpl authRepository;

    const testUser = UserEntity(
      id: 'user_001',
      fullName: 'Sunil Kumar',
      phoneNumber: '9876543210',
      role: UserRole.collector,
      address: UserAddressEntity(city: 'Mumbai', state: 'Maharashtra'),
    );

    const updatedBackendUser = UserEntity(
      id: 'user_001',
      fullName: 'Sunil Kumar Updated',
      phoneNumber: '9876543210',
      role: UserRole.collector,
      address: UserAddressEntity(city: 'Pune', state: 'Maharashtra'),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      tokenStorage = SharedPreferencesAuthTokenStorage(prefs: prefs);
      mockRemoteDataSource = MockAuthRemoteDataSource();
      apiClient = ApiClient();
      authRepository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenStorage: tokenStorage,
        apiClient: apiClient,
      );
    });

    test('A. Online startup: Valid tokens + backend reachable refreshes cached user', () async {
      await tokenStorage.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );
      await tokenStorage.saveUser(testUser);

      mockRemoteDataSource.userToReturn = UserModel.fromEntity(
        updatedBackendUser,
      );

      final session = await authRepository.restoreSession();

      expect(session, isNotNull);
      expect(session!.user.fullName, equals('Sunil Kumar Updated'));
      expect(session.user.address?.city, equals('Pune'));

      // Verify cached user in storage was updated with latest backend data
      final cached = await tokenStorage.getUser();
      expect(cached, isNotNull);
      expect(cached!.fullName, equals('Sunil Kumar Updated'));
      expect(cached.address?.city, equals('Pune'));
    });

    test(
      'B. Offline startup: Network failure falls back to cached UserEntity',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'valid_access_token',
          refreshToken: 'valid_refresh_token',
        );
        await tokenStorage.saveUser(testUser);

        // Backend throws network error (offline)
        mockRemoteDataSource.errorToThrow = ApiException.network();

        final session = await authRepository.restoreSession();

        // Must NOT logout; restore session using cached identity
        expect(session, isNotNull);
        expect(session!.user.id, equals('user_001'));
        expect(session.user.fullName, equals('Sunil Kumar'));
        expect(session.accessToken, equals('valid_access_token'));

        // Tokens must remain intact in storage
        expect(
          await tokenStorage.getAccessToken(),
          equals('valid_access_token'),
        );
      },
    );

    test(
      'C. Offline startup: Timeout failure falls back to cached UserEntity',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'valid_access_token',
          refreshToken: 'valid_refresh_token',
        );
        await tokenStorage.saveUser(testUser);

        // Backend throws timeout error
        mockRemoteDataSource.errorToThrow = ApiException.timeout();

        final session = await authRepository.restoreSession();

        expect(session, isNotNull);
        expect(session!.user.id, equals('user_001'));
        expect(session.user.fullName, equals('Sunil Kumar'));
      },
    );

    test('D. Auth failure (401): Purges cached user and tokens on invalid credentials', () async {
      await tokenStorage.saveTokens(
        accessToken: 'expired_access_token',
        refreshToken: 'expired_refresh_token',
      );
      await tokenStorage.saveUser(testUser);

      // Backend returns 401 Unauthorized, refresh fails
      mockRemoteDataSource.errorToThrow = ApiException.unauthorized();
      mockRemoteDataSource.refreshShouldSucceed = false;

      final session = await authRepository.restoreSession();

      // Must return null (logout)
      expect(session, isNull);

      // Tokens and cached user MUST be completely cleared from storage
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
      expect(await tokenStorage.getUser(), isNull);
    });

    test(
      'E. Offline startup without cached user: Returns null safely',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'valid_access_token',
          refreshToken: 'valid_refresh_token',
        );
        // No cached user in storage

        mockRemoteDataSource.errorToThrow = ApiException.network();

        final session = await authRepository.restoreSession();

        expect(session, isNull);
      },
    );

    test(
      'F. Cache persistence: Serialization and corruption tolerance',
      () async {
        // 1. Save and retrieve full user entity
        await tokenStorage.saveUser(testUser);
        final retrieved = await tokenStorage.getUser();

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(testUser.id));
        expect(retrieved.fullName, equals(testUser.fullName));
        expect(retrieved.role, equals(testUser.role));
        expect(retrieved.address?.city, equals('Mumbai'));

        // 2. Corrupt data resilience: set corrupt JSON in preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_cached_user', '{invalid_json:');

        final corruptResult = await tokenStorage.getUser();
        // Must not throw; returns null safely
        expect(corruptResult, isNull);

        // 3. Clear user
        await tokenStorage.saveUser(testUser);
        await tokenStorage.clearUser();
        expect(await tokenStorage.getUser(), isNull);
      },
    );

    test('G. Login and logout cache handling', () async {
      mockRemoteDataSource.userToReturn = UserModel.fromEntity(testUser);

      final loginSession = await authRepository.login(
        phoneNumber: '9876543210',
        password: 'password123',
      );

      expect(loginSession.user.id, equals('user_001'));
      // Verifies user was automatically cached during login
      final cachedAfterLogin = await tokenStorage.getUser();
      expect(cachedAfterLogin, isNotNull);
      expect(cachedAfterLogin!.id, equals('user_001'));

      // Logout clears tokens and cached user
      await authRepository.logout();
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getUser(), isNull);
    });
  });
}
