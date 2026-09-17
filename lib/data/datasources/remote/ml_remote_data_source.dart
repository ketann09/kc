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

String _mapCategoryToML(String category) {
  final cat = category.trim();
  final lower = cat.toLowerCase();
  if (lower.contains('plastic') || lower.contains('प्लास्टिक')) {
    return 'Plastic';
  }
  if (lower.contains('battery') || lower.contains('बैटरी')) {
    return 'Battery';
  }
  if (lower.contains('wire') ||
      lower.contains('cable') ||
      lower.contains('केबल')) {
    return 'Wires';
  }
  if (lower.contains('metal') ||
      lower.contains('धातु') ||
      lower.contains('लोहा')) {
    return 'Wires';
  }
  if (lower.contains('pcb') ||
      lower.contains('e-waste') ||
      lower.contains('ई-वेस्ट')) {
    return 'PCB';
  }
  if (lower.contains('motor')) return 'Motors';
  if (lower.contains('crt')) return 'CRT';
  if (lower.contains('lcd') || lower.contains('led')) return 'LCD_LED';
  return cat;
}

String _normalizeLocationName(String name) {
  final trimmed = name.trim();
  const locationMap = {
    'उत्तर प्रदेश': 'Uttar Pradesh',
    'दिल्ली': 'Delhi',
    'हरियाणा': 'Haryana',
    'राजस्थान': 'Rajasthan',
    'महाराष्ट्र': 'Maharashtra',
    'मध्य प्रदेश': 'Madhya Pradesh',
    'गाज़ियाबाद': 'Ghaziabad',
    'नोएडा': 'Noida',
    'लखनऊ': 'Lucknow',
    'कानपुर': 'Kanpur',
    'आगरा': 'Agra',
    'वाराणसी': 'Varanasi',
    'नई दिल्ली': 'New Delhi',
    'उत्तर दिल्ली': 'North Delhi',
    'दक्षिण दिल्ली': 'South Delhi',
    'पूर्वी दिल्ली': 'East Delhi',
    'गुरुग्राम': 'Gurugram',
    'फरीदाबाद': 'Faridabad',
    'पानीपत': 'Panipat',
    'रोहतक': 'Rohtak',
    'जयपुर': 'Jaipur',
    'जोधपुर': 'Jodhpur',
    'उदयपुर': 'Udaipur',
    'कोटा': 'Kota',
    'मुंबई': 'Mumbai',
    'पुणे': 'Pune',
    'नागपुर': 'Nagpur',
    'नासिक': 'Nasik',
    'भोपाल': 'Bhopal',
    'इंदौर': 'Indore',
    'ग्वालियर': 'Gwalior',
    'जबलपुर': 'Jabalpur',
  };
  return locationMap[trimmed] ?? trimmed;
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
    final mappedCategory = _mapCategoryToML(category);
    final mappedState = _normalizeLocationName(state);
    final mappedCity = _normalizeLocationName(city);

    final response = await apiClient.post<Map<String, dynamic>>(
      '/ml/price',
      data: {
        'category': mappedCategory,
        'state': mappedState,
        'city': mappedCity,
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
    final mappedState = _normalizeLocationName(state);
    final mappedCity = _normalizeLocationName(city);

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
      'state': mappedState,
      'city': mappedCity,
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
