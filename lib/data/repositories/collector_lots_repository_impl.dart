import '../../../domain/entities/lot_entity.dart';
import '../../../domain/repositories/collector_lots_repository.dart';
import '../datasources/remote/lots_remote_data_source.dart';

class CollectorLotsRepositoryImpl implements CollectorLotsRepository {
  final LotsRemoteDataSource remoteDataSource;

  CollectorLotsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LotEntity> createLot(CreateLotParams params) {
    return remoteDataSource.createLot(params);
  }

  @override
  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return remoteDataSource.getCollectorLots(
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
}
