import '../entities/matchmaking_result_entity.dart';

abstract class MatchmakingRepository {
  Future<MatchmakingResultEntity> findRecyclersForLot(String lotId);

  Future<MatchmakingResultEntity> autoMatchLot(String lotId);
}
