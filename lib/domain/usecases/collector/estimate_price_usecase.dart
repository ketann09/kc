import '../../entities/ml_price_entity.dart';
import '../../repositories/ml_repository.dart';

class EstimatePriceUseCase {
  final MLRepository _repository;

  const EstimatePriceUseCase(this._repository);

  Future<MLPriceEntity> call({
    required String category,
    required String state,
    required String city,
    int quantity = 1,
    required double totalWeightKg,
  }) {
    return _repository.predictPrice(
      category: category,
      state: state,
      city: city,
      quantity: quantity,
      totalWeightKg: totalWeightKg,
    );
  }
}
