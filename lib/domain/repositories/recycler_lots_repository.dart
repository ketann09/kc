import '../entities/lot_entity.dart';

abstract class RecyclerLotsRepository {
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<LotEntity> getLotById(String lotId);

  Future<LotEntity> acceptLot({required String lotId, double? price});
}
