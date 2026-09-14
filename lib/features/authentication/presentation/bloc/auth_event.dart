import 'package:equatable/equatable.dart';

import '../../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered on app startup to inspect and restore cached auth credentials
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when user submits phone/password credentials
class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const AuthLoginRequested({required this.phoneNumber, required this.password});

  @override
  List<Object?> get props => [phoneNumber, password];
}

/// Event triggered when user registers a new account
class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String phoneNumber;
  final String password;
  final String? email;
  final UserRole role;
  final UserAddressEntity? address;
  final String? profilePicturePath;

  const AuthRegisterRequested({
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    this.email,
    this.role = UserRole.collector,
    this.address,
    this.profilePicturePath,
  });

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    password,
    email,
    role,
    address,
    profilePicturePath,
  ];
}

/// Event triggered when user logs out
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
