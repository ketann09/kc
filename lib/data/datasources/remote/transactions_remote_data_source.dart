import '../../../core/network/api_client.dart';
import '../../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<TransactionModel> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  });

  Future<TransactionModel> getTransactionById(String transactionId);

  Future<List<TransactionModel>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<List<TransactionModel>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<TransactionModel> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  });

  Future<TransactionModel> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final ApiClient apiClient;

  TransactionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TransactionModel> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'lotId': lotId,
      'paymentMethod': paymentMethod,
      'amount': amount,
    };

    if (actualWeight != null || estimatedWeight != null) {
      final weightDetails = <String, dynamic>{};
      if (actualWeight != null) weightDetails['actualWeight'] = actualWeight;
      if (estimatedWeight != null) weightDetails['estimatedWeight'] = estimatedWeight;
      payload['weightDetails'] = weightDetails;
    }

    if (notes != null && notes.trim().isNotEmpty) {
      payload['notes'] = notes.trim();
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      '/transactions',
      data: payload,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Failed to create transaction');
    }

    final txData = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return TransactionModel.fromJson(txData);
  }

  @override
  Future<TransactionModel> getTransactionById(String transactionId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/transactions/$transactionId',
    );

    final raw = response.data;
    if (raw == null || raw['data'] == null) {
      throw Exception('Transaction not found');
    }

    final txData = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return TransactionModel.fromJson(txData);
  }

  @override
  Future<List<TransactionModel>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final response = await apiClient.get<Map<String, dynamic>>(
      '/transactions/collector',
      queryParameters: query,
    );

    return _parseTransactionList(response.data);
  }

  @override
  Future<List<TransactionModel>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final response = await apiClient.get<Map<String, dynamic>>(
      '/transactions/recycler',
      queryParameters: query,
    );

    return _parseTransactionList(response.data);
  }

  @override
  Future<TransactionModel> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) async {
    final payload = <String, dynamic>{};
    if (handoverPhotos != null) {
      payload['handoverPhotos'] = handoverPhotos;
    }
    if (latitude != null || longitude != null) {
      final gps = <String, dynamic>{};
      if (latitude != null) gps['latitude'] = latitude;
      if (longitude != null) gps['longitude'] = longitude;
      payload['handoverGPS'] = gps;
    }
    if (receivedBy != null && receivedBy.trim().isNotEmpty) {
      payload['receivedBy'] = receivedBy.trim();
    }
    if (verifiedBy != null && verifiedBy.trim().isNotEmpty) {
      payload['verifiedBy'] = verifiedBy.trim();
    }

    final response = await apiClient.patch<Map<String, dynamic>>(
      '/transactions/$transactionId/handover',
      data: payload,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Failed to update handover details');
    }

    final txData = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return TransactionModel.fromJson(txData);
  }

  @override
  Future<TransactionModel> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async {
    final payload = <String, dynamic>{
      'paymentStatus': paymentStatus,
    };
    if (paymentTransactionId != null && paymentTransactionId.trim().isNotEmpty) {
      payload['transactionId'] = paymentTransactionId.trim();
    }
    if (receiptUrl != null && receiptUrl.trim().isNotEmpty) {
      payload['receiptUrl'] = receiptUrl.trim();
    }

    final response = await apiClient.patch<Map<String, dynamic>>(
      '/transactions/$transactionId/payment',
      data: payload,
    );

    final raw = response.data;
    if (raw == null) {
      throw Exception('Failed to update payment status');
    }

    final txData = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    return TransactionModel.fromJson(txData);
  }

  List<TransactionModel> _parseTransactionList(dynamic rawData) {
    if (rawData == null) return [];
    final dataField = rawData is Map ? rawData['data'] : null;

    List? list;
    if (dataField is Map) {
      list = (dataField['transactions'] ?? dataField['data']) as List?;
    } else if (dataField is List) {
      list = dataField;
    } else if (rawData is List) {
      list = rawData;
    }

    return list
            ?.whereType<Map>()
            .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
  }
}
