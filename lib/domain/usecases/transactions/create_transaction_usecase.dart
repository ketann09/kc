import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class CreateTransactionUseCase {
  final TransactionsRepository repository;

  const CreateTransactionUseCase(this.repository);

  Future<TransactionEntity> call({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) {
    return repository.createTransaction(
      lotId: lotId,
      paymentMethod: paymentMethod,
      amount: amount,
      actualWeight: actualWeight,
      estimatedWeight: estimatedWeight,
      notes: notes,
    );
  }
}
