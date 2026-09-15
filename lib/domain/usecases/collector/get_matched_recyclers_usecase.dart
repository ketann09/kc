import '../../entities/matchmaking_result_entity.dart';
import '../../repositories/matchmaking_repository.dart';

class GetMatchedRecyclersUseCase {
  final MatchmakingRepository _repository;

  const GetMatchedRecyclersUseCase(this._repository);

  Future<MatchmakingResultEntity> call(String lotId) {
    return _repository.findRecyclersForLot(lotId);
  }

  Future<MatchmakingResultEntity> autoMatch(String lotId) {
    return _repository.autoMatchLot(lotId);
  }
}
