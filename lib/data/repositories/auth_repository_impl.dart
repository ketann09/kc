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

    // Update ApiClient with active token
    apiClient.setAccessToken(response.accessToken);

    return response.toEntity();
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
    return await remoteDataSource.getCurrentUser();
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
      return AuthSessionEntity(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on ApiException catch (e) {
      if (e.type == ApiExceptionType.unauthorized || e.statusCode == 401) {
        try {
          final newAccessToken = await refreshAccessToken();
          final updatedRefreshToken = (await tokenStorage.getRefreshToken()) ?? refreshToken;
          final user = await remoteDataSource.getCurrentUser();
          return AuthSessionEntity(
            user: user,
            accessToken: newAccessToken,
            refreshToken: updatedRefreshToken,
          );
        } catch (_) {
          await tokenStorage.clearTokens();
          apiClient.clearAccessToken();
          return null;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
