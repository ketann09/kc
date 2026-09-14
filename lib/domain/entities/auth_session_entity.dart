import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class AuthSessionEntity extends Equatable {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  const AuthSessionEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
