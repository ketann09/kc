import '../../entities/lot_entity.dart';
import '../../repositories/recycler_lots_repository.dart';

class GetRecyclerLotDetailsUseCase {
  final RecyclerLotsRepository repository;

  const GetRecyclerLotDetailsUseCase(this.repository);

  Future<LotEntity> call(String lotId) {
    return repository.getLotById(lotId);
  }
}
