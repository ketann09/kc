import '../../entities/lot_entity.dart';
import '../../repositories/recycler_lots_repository.dart';

class AcceptRecyclerLotUseCase {
  final RecyclerLotsRepository repository;

  const AcceptRecyclerLotUseCase(this.repository);

  Future<LotEntity> call({required String lotId, double? price}) {
    return repository.acceptLot(lotId: lotId, price: price);
  }
}
