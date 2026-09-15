import '../../entities/material_entity.dart';
import '../../repositories/materials_repository.dart';

class GetLiveScrapRatesUseCase {
  final MaterialsRepository _repository;

  const GetLiveScrapRatesUseCase(this._repository);

  Future<List<MaterialEntity>> call({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) {
    return _repository.getAllMaterials(
      page: page,
      limit: limit,
      category: category,
      search: search,
    );
  }
}
