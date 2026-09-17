import '../../entities/lot_entity.dart';
import '../../repositories/recycler_lots_repository.dart';

class GetRecyclerLotsUseCase {
  final RecyclerLotsRepository repository;

  const GetRecyclerLotsUseCase(this.repository);

  Future<List<LotEntity>> call({int page = 1, int limit = 10, String? status}) {
    return repository.getRecyclerLots(page: page, limit: limit, status: status);
  }
}
