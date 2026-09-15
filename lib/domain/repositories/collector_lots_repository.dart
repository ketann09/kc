import '../entities/lot_entity.dart';

abstract class CollectorLotsRepository {
  Future<LotEntity> createLot(CreateLotParams params);

  Future<List<LotEntity>> getCollectorLots({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<LotEntity> getLotById(String lotId);

  Future<LotEntity> acceptLot({required String lotId, double? price});
}
