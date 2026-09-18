import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class GetTransactionByIdUseCase {
  final TransactionsRepository repository;

  const GetTransactionByIdUseCase(this.repository);

  Future<TransactionEntity> call(String transactionId) {
    return repository.getTransactionById(transactionId);
  }
}
