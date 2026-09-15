import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/lot_entity.dart';
import '../../models/lot_model.dart';

abstract class LotsRemoteDataSource {
  Future<LotModel> createLot(CreateLotParams params);

  Future<List<LotModel>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<LotModel> getLotById(String lotId);

  Future<LotModel> acceptLot({required String lotId, double? price});
}

class LotsRemoteDataSourceImpl implements LotsRemoteDataSource {
  final ApiClient apiClient;

  LotsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LotModel> createLot(CreateLotParams params) async {
    final formData = FormData();

    // Add multipart image files
    for (final path in params.imagePaths) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(path)),
      );
    }

    // Add fields
    formData.fields.add(
      MapEntry('estimatedWeight', params.estimatedWeight.toString()),
    );

    if (params.estimatedPrice != null) {
      formData.fields.add(
        MapEntry('estimatedPrice', params.estimatedPrice.toString()),
      );
    }

    if (params.category != null && params.category!.isNotEmpty) {
      formData.fields.add(MapEntry('category', params.category!));
    }

    if (params.subCategory != null && params.subCategory!.isNotEmpty) {
      formData.fields.add(MapEntry('subCategory', params.subCategory!));
    }

    if (params.description != null && params.description!.isNotEmpty) {
      formData.fields.add(MapEntry('description', params.description!));
    }

    if (params.materialId != null && params.materialId!.isNotEmpty) {
      formData.fields.add(MapEntry('materialId', params.materialId!));
    }

    if (params.state != null && params.state!.isNotEmpty) {
      formData.fields.add(MapEntry('state', params.state!));
    }

    if (params.city != null && params.city!.isNotEmpty) {
      formData.fields.add(MapEntry('city', params.city!));
    }

    formData.fields.add(MapEntry('quantity', params.quantity.toString()));

    if (params.confirmCategory != null && params.confirmCategory!.isNotEmpty) {
      formData.fields.add(MapEntry('confirmCategory', params.confirmCategory!));
    }

    if (params.schedulePickup != null) {
      formData.fields.add(
        MapEntry('schedulePickup', jsonEncode(params.schedulePickup)),
      );
    }

    // Format location as GeoJSON JSON string
    final locationMap = <String, dynamic>{
      'type': 'Point',
      'coordinates': [
        params.location.longitude ?? 0.0,
        params.location.latitude ?? 0.0,
      ],
    };
    if (params.location.address != null &&
        params.location.address!.isNotEmpty) {
      locationMap['address'] = params.location.address;
    }
    if (params.location.pickupAddress != null &&
        params.location.pickupAddress!.isNotEmpty) {
      locationMap['pickupAddress'] = params.location.pickupAddress;
    }
    if (params.location.state != null && params.location.state!.isNotEmpty) {
      locationMap['state'] = params.location.state;
    } else if (params.state != null && params.state!.isNotEmpty) {
      locationMap['state'] = params.state;
    }
    if (params.location.city != null && params.location.city!.isNotEmpty) {
      locationMap['city'] = params.location.city;
    } else if (params.city != null && params.city!.isNotEmpty) {
      locationMap['city'] = params.city;
    }

    formData.fields.add(MapEntry('location', jsonEncode(locationMap)));

    final response = await apiClient.post<Map<String, dynamic>>(
      '/lots',
      data: formData,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Empty response when creating lot');
    }

    return LotModel.fromJson(raw);
  }

  @override
  Future<List<LotModel>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await apiClient.get<Map<String, dynamic>>(
      '/lots/collector',
      queryParameters: queryParams,
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      return [];
    }

    final dynamic dataField = raw['data'];
    List? list;
    if (dataField is Map) {
      list = (dataField['lots'] ?? dataField['data']) as List?;
    } else if (dataField is List) {
      list = dataField;
    }

    return list
            ?.whereType<Map>()
            .map((e) => LotModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
  }

  @override
  Future<LotModel> getLotById(String lotId) async {
    final response = await apiClient.get<Map<String, dynamic>>('/lots/$lotId');
    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Lot not found');
    }

    final data = raw['data'];
    if (data is Map) {
      return LotModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid lot data response');
  }

  @override
  Future<LotModel> acceptLot({required String lotId, double? price}) async {
    final data = <String, dynamic>{};
    if (price != null) {
      data['price'] = price;
    }

    final response = await apiClient.patch<Map<String, dynamic>>(
      '/lots/$lotId/accept',
      data: data.isNotEmpty ? data : null,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Failed to accept lot');
    }

    final lotData = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return LotModel.fromJson(lotData);
  }
}
