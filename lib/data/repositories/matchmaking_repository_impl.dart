import '../../../domain/entities/matchmaking_result_entity.dart';
import '../../../domain/repositories/matchmaking_repository.dart';
import '../datasources/remote/matchmaking_remote_data_source.dart';

class MatchmakingRepositoryImpl implements MatchmakingRepository {
  final MatchmakingRemoteDataSource remoteDataSource;

  MatchmakingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MatchmakingResultEntity> findRecyclersForLot(String lotId) {
    return remoteDataSource.findRecyclersForLot(lotId);
  }

  @override
  Future<MatchmakingResultEntity> autoMatchLot(String lotId) {
    return remoteDataSource.autoMatchLot(lotId);
  }
}
