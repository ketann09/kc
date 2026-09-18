import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class GetCollectorTransactionsUseCase {
  final TransactionsRepository repository;

  const GetCollectorTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return repository.getCollectorTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
