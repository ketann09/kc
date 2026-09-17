import '../../entities/lot_entity.dart';
import '../../repositories/recycler_lots_repository.dart';

class UpdateLotLifecycleUseCase {
  final RecyclerLotsRepository repository;

  const UpdateLotLifecycleUseCase(this.repository);

  Future<LotEntity> call({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) {
    return repository.updateLotLifecycle(
      lotId: lotId,
      status: status,
      actualWeight: actualWeight,
      finalPrice: finalPrice,
    );
  }
}
