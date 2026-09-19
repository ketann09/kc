import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../domain/entities/auth_session_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthTokenStorage tokenStorage;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.apiClient,
  });

  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    // Save tokens locally
    await tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    final session = response.toEntity();

    // Cache user profile for offline session resilience
    await tokenStorage.saveUser(session.user);

    // Update ApiClient with active token
    apiClient.setAccessToken(response.accessToken);

    return session;
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
    final user = await remoteDataSource.register(
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      email: email,
      role: role,
      address: address,
      profilePicturePath: profilePicturePath,
    );

    return user;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    await tokenStorage.saveUser(user);
    return user;
  }

  @override
  Future<String> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException.unauthorized(
        message: 'No refresh token stored locally',
      );
    }

    final tokens = await remoteDataSource.refreshAccessToken(refreshToken);
    final newAccessToken = tokens['accessToken']!;
    final newRefreshToken = tokens['refreshToken']!;

    await tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    apiClient.setAccessToken(newAccessToken);

    return newAccessToken;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore network errors on logout to allow local session cleanup
    } finally {
      await tokenStorage.clearTokens();
      await tokenStorage.clearUser();
      apiClient.clearAccessToken();
    }
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    final accessToken = await tokenStorage.getAccessToken();
    final refreshToken = await tokenStorage.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    apiClient.setAccessToken(accessToken);

    try {
      final user = await remoteDataSource.getCurrentUser();
      // Refresh local cache with latest authoritative user profile from backend
      await tokenStorage.saveUser(user);
      return AuthSessionEntity(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on ApiException catch (e) {
      if (e.isAuthError) {
        // Genuine authentication failure (401/403): attempt token refresh
        try {
          final newAccessToken = await refreshAccessToken();
          final updatedRefreshToken =
              (await tokenStorage.getRefreshToken()) ?? refreshToken;
          final user = await remoteDataSource.getCurrentUser();
          await tokenStorage.saveUser(user);
          return AuthSessionEntity(
            user: user,
            accessToken: newAccessToken,
            refreshToken: updatedRefreshToken,
          );
        } catch (_) {
          // Token refresh failed: purge stored credentials and cached profile
          await tokenStorage.clearTokens();
          await tokenStorage.clearUser();
          apiClient.clearAccessToken();
          return null;
        }
      } else if (e.isNetworkError || e.isTimeout) {
        // Network or timeout failure during startup:
        // Do NOT discard valid authentication credentials. Fallback to cached identity.
        final cachedUser = await tokenStorage.getUser();
        if (cachedUser != null) {
          return AuthSessionEntity(
            user: cachedUser,
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return null;
      }
      return null;
    } catch (_) {
      // Non-ApiException failure (e.g. unexpected socket or decode failure):
      // Safely attempt offline session restoration from cached profile.
      final cachedUser = await tokenStorage.getUser();
      if (cachedUser != null) {
        return AuthSessionEntity(
          user: cachedUser,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return null;
    }
  }
}
