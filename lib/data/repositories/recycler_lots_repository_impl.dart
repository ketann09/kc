import '../../../domain/entities/lot_entity.dart';
import '../../../domain/repositories/recycler_lots_repository.dart';
import '../datasources/remote/lots_remote_data_source.dart';

class RecyclerLotsRepositoryImpl implements RecyclerLotsRepository {
  final LotsRemoteDataSource remoteDataSource;

  RecyclerLotsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return remoteDataSource.getRecyclerLots(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<LotEntity> getLotById(String lotId) {
    return remoteDataSource.getLotById(lotId);
  }

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) {
    return remoteDataSource.acceptLot(lotId: lotId, price: price);
  }

  @override
  Future<LotEntity> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) {
    return remoteDataSource.updateLotLifecycle(
      lotId: lotId,
      status: status,
      actualWeight: actualWeight,
      finalPrice: finalPrice,
    );
  }
}
