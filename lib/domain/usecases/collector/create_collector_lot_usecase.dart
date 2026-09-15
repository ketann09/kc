import '../../entities/lot_entity.dart';
import '../../repositories/collector_lots_repository.dart';

class CreateCollectorLotUseCase {
  final CollectorLotsRepository _repository;

  const CreateCollectorLotUseCase(this._repository);

  Future<LotEntity> call(CreateLotParams params) {
    return _repository.createLot(params);
  }
}
