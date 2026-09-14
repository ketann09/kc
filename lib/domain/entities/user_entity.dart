import 'package:equatable/equatable.dart';

enum UserRole {
  collector('collector'),
  recycler('recycler'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.collector;
    switch (role.toLowerCase().trim()) {
      case 'recycler':
        return UserRole.recycler;
      case 'admin':
        return UserRole.admin;
      case 'collector':
      default:
        return UserRole.collector;
    }
  }
}

class UserAddressEntity extends Equatable {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const UserAddressEntity({
    this.street,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    street,
    city,
    state,
    pincode,
    latitude,
    longitude,
  ];
}

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final UserRole role;
  final String? profilePicture;
  final UserAddressEntity? address;
  final bool isVerified;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.role = UserRole.collector,
    this.profilePicture,
    this.address,
    this.isVerified = false,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    email,
    role,
    profilePicture,
    address,
    isVerified,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
  ];
}
