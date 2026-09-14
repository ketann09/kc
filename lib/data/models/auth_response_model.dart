import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // If the top-level payload is passed or just the nested data map:
    final data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }

  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
