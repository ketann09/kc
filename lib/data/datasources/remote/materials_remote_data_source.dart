import '../../../core/network/api_client.dart';
import '../../models/material_model.dart';

abstract class MaterialsRemoteDataSource {
  Future<List<MaterialModel>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  });

  Future<List<Map<String, dynamic>>> getCategories();

  Future<MaterialModel> getMaterialById(String materialId);
}

class MaterialsRemoteDataSourceImpl implements MaterialsRemoteDataSource {
  final ApiClient apiClient;

  MaterialsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MaterialModel>> getAllMaterials({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiClient.get<Map<String, dynamic>>(
      '/materials',
      queryParameters: queryParams,
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      return [];
    }

    final dynamic dataField = raw['data'];
    List? list;
    if (dataField is Map) {
      list = (dataField['materials'] ?? dataField['data']) as List?;
    } else if (dataField is List) {
      list = dataField;
    }

    return list
            ?.whereType<Map>()
            .map((e) => MaterialModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/materials/categories',
    );
    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      return [];
    }

    final list = raw['data'] as List?;
    return list
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
  }

  @override
  Future<MaterialModel> getMaterialById(String materialId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/materials/$materialId',
    );
    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Material not found');
    }

    final data = raw['data'];
    if (data is Map) {
      return MaterialModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid material data response');
  }
}
