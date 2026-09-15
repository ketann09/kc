import '../../../domain/entities/ml_classification_entity.dart';
import '../../../domain/entities/ml_predict_and_price_result_entity.dart';
import '../../../domain/entities/ml_price_entity.dart';
import '../../../domain/repositories/ml_repository.dart';
import '../datasources/remote/ml_remote_data_source.dart';

class MLRepositoryImpl implements MLRepository {
  final MLRemoteDataSource remoteDataSource;

  MLRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MLClassificationEntity> classifyImage({required String imagePath}) {
    return remoteDataSource.classifyImage(imagePath: imagePath);
  }

  @override
  Future<MLPriceEntity> predictPrice({
    required String category,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) {
    return remoteDataSource.predictPrice(
      category: category,
      state: state,
      city: city,
      quantity: quantity,
      totalWeightKg: totalWeightKg,
    );
  }

  @override
  Future<MLPredictAndPriceResultEntity> predictAndPrice({
    required String imagePath,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) {
    return remoteDataSource.predictAndPrice(
      imagePath: imagePath,
      state: state,
      city: city,
      quantity: quantity,
      totalWeightKg: totalWeightKg,
    );
  }

  @override
  Future<List<String>> getCategories() {
    return remoteDataSource.getCategories();
  }
}
