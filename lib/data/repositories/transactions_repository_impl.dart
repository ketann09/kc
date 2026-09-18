import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transactions_repository.dart';
import '../datasources/remote/transactions_remote_data_source.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;

  TransactionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) {
    return remoteDataSource.createTransaction(
      lotId: lotId,
      paymentMethod: paymentMethod,
      amount: amount,
      actualWeight: actualWeight,
      estimatedWeight: estimatedWeight,
      notes: notes,
    );
  }

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) {
    return remoteDataSource.getTransactionById(transactionId);
  }

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return remoteDataSource.getCollectorTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return remoteDataSource.getRecyclerTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<TransactionEntity> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) {
    return remoteDataSource.updateHandoverDetails(
      transactionId: transactionId,
      handoverPhotos: handoverPhotos,
      latitude: latitude,
      longitude: longitude,
      receivedBy: receivedBy,
      verifiedBy: verifiedBy,
    );
  }

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) {
    return remoteDataSource.updatePaymentStatus(
      transactionId: transactionId,
      paymentStatus: paymentStatus,
      paymentTransactionId: paymentTransactionId,
      receiptUrl: receiptUrl,
    );
  }
}
