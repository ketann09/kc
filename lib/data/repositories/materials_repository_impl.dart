import '../../../domain/entities/material_entity.dart';
import '../../../domain/repositories/materials_repository.dart';
import '../datasources/remote/materials_remote_data_source.dart';

class MaterialsRepositoryImpl implements MaterialsRepository {
  final MaterialsRemoteDataSource remoteDataSource;

  MaterialsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) {
    return remoteDataSource.getAllMaterials(
      page: page,
      limit: limit,
      category: category,
      search: search,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() {
    return remoteDataSource.getCategories();
  }

  @override
  Future<MaterialEntity> getMaterialById(String materialId) {
    return remoteDataSource.getMaterialById(materialId);
  }
}
