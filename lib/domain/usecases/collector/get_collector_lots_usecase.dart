import '../../entities/lot_entity.dart';
import '../../repositories/collector_lots_repository.dart';

class GetCollectorLotsUseCase {
  final CollectorLotsRepository _repository;

  const GetCollectorLotsUseCase(this._repository);

  Future<List<LotEntity>> call({int page = 1, int limit = 10, String? status}) {
    return _repository.getCollectorLots(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
