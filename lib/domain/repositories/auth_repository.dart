import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Authenticates user with phone number and password.
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  });

  /// Registers a new user account with role and optional address/profile picture.
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  });

  /// Fetches the current authenticated user profile using active token.
  Future<UserEntity> getCurrentUser();

  /// Refreshes the active access token using the stored refresh token.
  Future<String> refreshAccessToken();

  /// Logs out user, invalidating session both on server and locally.
  Future<void> logout();

  /// Restores session on app startup if valid credentials exist.
  Future<AuthSessionEntity?> restoreSession();
}
