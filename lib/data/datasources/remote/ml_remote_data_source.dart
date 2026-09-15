import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/ml_predict_and_price_result_entity.dart';
import '../../models/ml_classification_model.dart';
import '../../models/ml_price_model.dart';

abstract class MLRemoteDataSource {
  Future<MLClassificationModel> classifyImage({required String imagePath});

  Future<MLPriceModel> predictPrice({
    required String category,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  });

  Future<MLPredictAndPriceResultEntity> predictAndPrice({
    required String imagePath,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  });

  Future<List<String>> getCategories();
}

class MLRemoteDataSourceImpl implements MLRemoteDataSource {
  final ApiClient apiClient;

  MLRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MLClassificationModel> classifyImage({
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      '/ml/classify',
      data: formData,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Empty response from ML classify endpoint');
    }

    return MLClassificationModel.fromJson(raw);
  }

  @override
  Future<MLPriceModel> predictPrice({
    required String category,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/ml/price',
      data: {
        'category': category.trim(),
        'state': state.trim(),
        'city': city.trim(),
        'quantity': quantity,
        'total_weight_kg': totalWeightKg,
      },
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Empty response from ML price endpoint');
    }

    return MLPriceModel.fromJson(raw);
  }

  @override
  Future<MLPredictAndPriceResultEntity> predictAndPrice({
    required String imagePath,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
      'state': state.trim(),
      'city': city.trim(),
      'quantity': quantity.toString(),
      'total_weight_kg': totalWeightKg.toString(),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      '/ml/predict-and-price',
      data: formData,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Empty response from ML predict-and-price endpoint');
    }

    final classificationField = raw['classification'];
    final pricingField = raw['pricing'];

    return MLPredictAndPriceResultEntity(
      classification: classificationField is Map
          ? MLClassificationModel.fromJson(
              Map<String, dynamic>.from(classificationField),
            )
          : null,
      pricing: pricingField is Map
          ? MLPriceModel.fromJson(Map<String, dynamic>.from(pricingField))
          : null,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/ml/categories',
    );
    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      return [];
    }

    final dataField = raw['data'];
    List? categories;
    if (dataField is Map) {
      categories = dataField['categories'] as List?;
    } else if (dataField is List) {
      categories = dataField;
    }
    return categories?.map((e) => e.toString()).toList() ?? [];
  }
}
