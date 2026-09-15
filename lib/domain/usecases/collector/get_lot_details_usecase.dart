import '../../entities/lot_entity.dart';
import '../../repositories/collector_lots_repository.dart';

class GetLotDetailsUseCase {
  final CollectorLotsRepository _repository;

  const GetLotDetailsUseCase(this._repository);

  Future<LotEntity> call(String lotId) {
    return _repository.getLotById(lotId);
  }
}
