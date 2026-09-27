import '../../domain/entities/user_entity.dart';

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class UserAddressModel extends UserAddressEntity {
  const UserAddressModel({
    super.street,
    super.city,
    super.state,
    super.pincode,
    super.latitude,
    super.longitude,
  });

  factory UserAddressModel.fromEntity(UserAddressEntity entity) {
    return UserAddressModel(
      street: entity.street,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    double? lat = _toDoubleNullable(json['latitude']) ??
        _toDoubleNullable(json['lat']);
    double? lng = _toDoubleNullable(json['longitude']) ??
        _toDoubleNullable(json['lng']);

    final coords = json['coordinates'] ?? json['location'];
    if (coords is Map) {
      final innerList = coords['coordinates'];
      if (innerList is List && innerList.length >= 2) {
        // GeoJSON standard: [longitude, latitude]
        lng ??= _toDoubleNullable(innerList[0]);
        lat ??= _toDoubleNullable(innerList[1]);
      }
    } else if (coords is List && coords.length >= 2) {
      lng ??= _toDoubleNullable(coords[0]);
      lat ??= _toDoubleNullable(coords[1]);
    }

    if (lat != null && lng != null && lat == 0.0 && lng == 0.0) {
      lat = null;
      lng = null;
    }

    return UserAddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (street != null) map['street'] = street;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (pincode != null) map['pincode'] = pincode;
    if (latitude != null &&
        longitude != null &&
        !(latitude == 0.0 && longitude == 0.0)) {
      map['latitude'] = latitude;
      map['longitude'] = longitude;
      map['coordinates'] = {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };
    }
    return map;
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    super.email,
    super.role,
    super.profilePicture,
    super.address,
    super.isVerified,
    super.isActive,
    super.lastLogin,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      role: entity.role,
      profilePicture: entity.profilePicture,
      address: entity.address != null
          ? UserAddressModel.fromEntity(entity.address!)
          : null,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      lastLogin: entity.lastLogin,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      profilePicture: json['profilePicture'] as String?,
      address: json['address'] is Map<String, dynamic>
          ? UserAddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      isVerified: json['isVerified'] == true,
      isActive: json['isActive'] != false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'role': role.value,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (address != null)
        'address': UserAddressModel.fromEntity(address!).toJson(),
      'isVerified': isVerified,
      'isActive': isActive,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
