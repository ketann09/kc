import '../entities/ml_classification_entity.dart';
import '../entities/ml_predict_and_price_result_entity.dart';
import '../entities/ml_price_entity.dart';

abstract class MLRepository {
  Future<MLClassificationEntity> classifyImage({required String imagePath});

  Future<MLPriceEntity> predictPrice({
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
