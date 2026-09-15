import '../../entities/ml_classification_entity.dart';
import '../../repositories/ml_repository.dart';

class ClassifyScrapImageUseCase {
  final MLRepository _repository;

  const ClassifyScrapImageUseCase(this._repository);

  Future<MLClassificationEntity> call({required String imagePath}) {
    return _repository.classifyImage(imagePath: imagePath);
  }
}
