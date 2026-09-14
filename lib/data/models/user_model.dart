import '../../domain/entities/user_entity.dart';

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
    double? lat;
    double? lng;

    final coords = json['coordinates'];
    if (coords is Map<String, dynamic>) {
      final innerList = coords['coordinates'];
      if (innerList is List && innerList.length >= 2) {
        // GeoJSON standard: [longitude, latitude]
        lng = (innerList[0] as num?)?.toDouble();
        lat = (innerList[1] as num?)?.toDouble();
      }
    } else if (coords is List && coords.length >= 2) {
      lng = (coords[0] as num?)?.toDouble();
      lat = (coords[1] as num?)?.toDouble();
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
    if (latitude != null && longitude != null) {
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
