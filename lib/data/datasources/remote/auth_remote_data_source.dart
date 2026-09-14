import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<UserModel> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  });

  Future<UserModel> getCurrentUser();

  Future<Map<String, String>> refreshAccessToken(String refreshToken);

  Future<void> logout();

  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    UserAddressEntity? address,
    String? profilePicturePath,
  });

  Future<UserModel> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/users/login',
      data: {
        'phoneNumber': phoneNumber.trim(),
        'password': password,
      },
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Empty response from login endpoint');
    }

    return AuthResponseModel.fromJson(raw);
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    Response<Map<String, dynamic>> response;

    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      final formDataMap = <String, dynamic>{
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
        'role': role.value,
        'profilePicture': await MultipartFile.fromFile(profilePicturePath),
      };

      if (email != null && email.trim().isNotEmpty) {
        formDataMap['email'] = email.trim();
      }

      if (address != null) {
        formDataMap['address'] = jsonEncode(
          UserAddressModel.fromEntity(address).toJson(),
        );
      }

      response = await apiClient.post<Map<String, dynamic>>(
        '/users/register',
        data: FormData.fromMap(formDataMap),
      );
    } else {
      final payload = <String, dynamic>{
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
        'role': role.value,
      };

      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim();
      }

      if (address != null) {
        payload['address'] = UserAddressModel.fromEntity(address).toJson();
      }

      response = await apiClient.post<Map<String, dynamic>>(
        '/users/register',
        data: payload,
      );
    }

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Invalid response received from register endpoint');
    }

    return UserModel.fromJson(raw['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>('/users/me');
    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to retrieve current user');
    }

    return UserModel.fromJson(raw['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, String>> refreshAccessToken(String refreshToken) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/users/refresh-token',
      data: {
        'refreshToken': refreshToken.trim(),
      },
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to refresh authentication token');
    }

    final data = raw['data'] as Map<String, dynamic>;
    return {
      'accessToken': data['accessToken']?.toString() ?? '',
      'refreshToken': data['refreshToken']?.toString() ?? refreshToken,
    };
  }

  @override
  Future<void> logout() async {
    await apiClient.post<Map<String, dynamic>>('/users/logout');
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    Response<Map<String, dynamic>> response;

    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      final formDataMap = <String, dynamic>{
        'profilePicture': await MultipartFile.fromFile(profilePicturePath),
      };

      if (fullName != null) formDataMap['fullName'] = fullName.trim();
      if (email != null) formDataMap['email'] = email.trim();
      if (address != null) {
        formDataMap['address'] = jsonEncode(
          UserAddressModel.fromEntity(address).toJson(),
        );
      }

      response = await apiClient.patch<Map<String, dynamic>>(
        '/users/update-profile',
        data: FormData.fromMap(formDataMap),
      );
    } else {
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName.trim();
      if (email != null) payload['email'] = email.trim();
      if (address != null) {
        payload['address'] = UserAddressModel.fromEntity(address).toJson();
      }

      response = await apiClient.patch<Map<String, dynamic>>(
        '/users/update-profile',
        data: payload,
      );
    }

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to update user profile');
    }

    return UserModel.fromJson(raw['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      '/users/update-location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address ?? '',
      },
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to update user location');
    }

    return UserModel.fromJson(raw['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.patch<Map<String, dynamic>>(
      '/users/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}
