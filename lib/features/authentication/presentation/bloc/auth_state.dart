import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state before any auth checks
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during login, registration, or token check
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with an active session
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated (no active session or logged out)
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Registration succeeded for a new user account
class AuthRegistrationSuccess extends AuthState {
  final UserEntity user;

  const AuthRegistrationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authentication or operation failed with an error message
class AuthFailure extends AuthState {
  final String message;
  final ApiException? lastException;

  const AuthFailure(this.message, {this.lastException});

  @override
  List<Object?> get props => [message];
}
