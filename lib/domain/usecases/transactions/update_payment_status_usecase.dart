import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class UpdatePaymentStatusUseCase {
  final TransactionsRepository repository;

  const UpdatePaymentStatusUseCase(this.repository);

  Future<TransactionEntity> call({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) {
    return repository.updatePaymentStatus(
      transactionId: transactionId,
      paymentStatus: paymentStatus,
      paymentTransactionId: paymentTransactionId,
      receiptUrl: receiptUrl,
    );
  }
}
