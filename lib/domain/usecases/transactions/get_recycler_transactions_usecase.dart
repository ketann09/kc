import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class GetRecyclerTransactionsUseCase {
  final TransactionsRepository repository;

  const GetRecyclerTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return repository.getRecyclerTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
