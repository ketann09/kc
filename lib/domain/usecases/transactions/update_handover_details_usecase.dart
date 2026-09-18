import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class UpdateHandoverDetailsUseCase {
  final TransactionsRepository repository;

  const UpdateHandoverDetailsUseCase(this.repository);

  Future<TransactionEntity> call({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) {
    return repository.updateHandoverDetails(
      transactionId: transactionId,
      handoverPhotos: handoverPhotos,
      latitude: latitude,
      longitude: longitude,
      receivedBy: receivedBy,
      verifiedBy: verifiedBy,
    );
  }
}
