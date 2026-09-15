import '../entities/material_entity.dart';

abstract class MaterialsRepository {
  Future<List<MaterialEntity>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  });

  Future<List<Map<String, dynamic>>> getCategories();

  Future<MaterialEntity> getMaterialById(String materialId);
}
