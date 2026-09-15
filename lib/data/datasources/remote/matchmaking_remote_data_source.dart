import '../../../core/network/api_client.dart';
import '../../models/matchmaking_result_model.dart';

abstract class MatchmakingRemoteDataSource {
  Future<MatchmakingResultModel> findRecyclersForLot(String lotId);

  Future<MatchmakingResultModel> autoMatchLot(String lotId);
}

class MatchmakingRemoteDataSourceImpl implements MatchmakingRemoteDataSource {
  final ApiClient apiClient;

  MatchmakingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MatchmakingResultModel> findRecyclersForLot(String lotId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/matchmaking/lot/$lotId',
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to find recyclers for lot');
    }

    final data = raw['data'];
    if (data is Map) {
      return MatchmakingResultModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid matchmaking response format');
  }

  @override
  Future<MatchmakingResultModel> autoMatchLot(String lotId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/matchmaking/lot/$lotId/auto',
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Failed to auto-match lot');
    }

    final data = raw['data'];
    if (data is Map) {
      return MatchmakingResultModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid auto-match response format');
  }
}
