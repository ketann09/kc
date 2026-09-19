import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/storage/read_cache_storage.dart';
import '../../../../../data/models/transaction_model.dart';
import '../../../../../domain/entities/transaction_entity.dart';
import '../../../../../domain/usecases/transactions/get_collector_transactions_usecase.dart';
import 'collector_transactions_event.dart';
import 'collector_transactions_state.dart';

class CollectorTransactionsBloc
    extends Bloc<CollectorTransactionsEvent, CollectorTransactionsState> {
  final GetCollectorTransactionsUseCase getCollectorTransactionsUseCase;
  final ReadCacheStorage? readCacheStorage;

  List<TransactionEntity> _allTransactions = [];

  CollectorTransactionsBloc({
    required this.getCollectorTransactionsUseCase,
    this.readCacheStorage,
  }) : super(const CollectorTransactionsInitial()) {
    on<FetchCollectorTransactionsEvent>(_onFetchTransactions);
    on<FilterCollectorTransactionsEvent>(_onFilterTransactions);
  }

  Future<void> _onFetchTransactions(
    FetchCollectorTransactionsEvent event,
    Emitter<CollectorTransactionsState> emit,
  ) async {
    final currentState = state;
    if (event.refresh && currentState is CollectorTransactionsLoaded) {
      emit(currentState.copyWith(isRefreshing: true, refreshError: null));
    } else {
      emit(const CollectorTransactionsLoading());
    }

    try {
      final transactions = await getCollectorTransactionsUseCase(
        page: 1,
        limit: 50,
      );

      _allTransactions = transactions;

      if (readCacheStorage != null) {
        await readCacheStorage!.saveList<TransactionEntity>(
          key: 'collector_transactions',
          data: transactions,
          toJson: (item) => TransactionModel.fromEntity(item).toJson(),
        );
      }

      final (total, pending, count) = _calculateEarnings(transactions);
      final filtered = _filterList(transactions, event.status);

      emit(
        CollectorTransactionsLoaded(
          transactions: filtered,
          totalEarnings: total,
          pendingEarnings: pending,
          completedCount: count,
          statusFilter: event.status,
          isOffline: false,
          isRefreshing: false,
        ),
      );
    } on ApiException catch (e) {
      final isOffline = e.isNetworkError || e.isTimeout;
      if (currentState is CollectorTransactionsLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: isOffline,
            refreshError: e.message,
          ),
        );
      } else {
        final cached = await readCacheStorage?.getList<TransactionEntity>(
          key: 'collector_transactions',
          fromJson: (json) => TransactionModel.fromJson(json),
        );
        if (cached != null) {
          _allTransactions = cached.data;
          final (total, pending, count) = _calculateEarnings(cached.data);
          final filtered = _filterList(cached.data, event.status);

          emit(
            CollectorTransactionsLoaded(
              transactions: filtered,
              totalEarnings: total,
              pendingEarnings: pending,
              completedCount: count,
              statusFilter: event.status,
              isOffline: true,
              cachedAt: cached.cachedAt,
              refreshError: e.message,
            ),
          );
        } else {
          emit(CollectorTransactionsFailure(e.message, isOffline: isOffline));
        }
      }
    } catch (e) {
      if (currentState is CollectorTransactionsLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: true,
            refreshError: e.toString(),
          ),
        );
      } else {
        emit(
          CollectorTransactionsFailure(
            'लेन-देन लोड करने में विफल: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _onFilterTransactions(
    FilterCollectorTransactionsEvent event,
    Emitter<CollectorTransactionsState> emit,
  ) {
    final currentState = state;
    if (currentState is! CollectorTransactionsLoaded) return;

    final filtered = _filterList(_allTransactions, event.status);

    emit(
      currentState.copyWith(transactions: filtered, statusFilter: event.status),
    );
  }

  List<TransactionEntity> _filterList(
    List<TransactionEntity> list,
    String? status,
  ) {
    if (status == null || status.isEmpty || status == 'all') {
      return list;
    }
    if (status == 'completed') {
      return list
          .where((t) => t.paymentStatus == PaymentStatus.completed)
          .toList();
    }
    if (status == 'pending') {
      return list
          .where((t) => t.paymentStatus == PaymentStatus.pending)
          .toList();
    }
    return list;
  }

  (double, double, int) _calculateEarnings(List<TransactionEntity> list) {
    double total = 0.0;
    double pending = 0.0;
    int count = 0;

    for (final txn in list) {
      final net = _resolveNetAmount(txn);
      if (txn.paymentStatus == PaymentStatus.completed) {
        total += net;
        count++;
      } else if (txn.paymentStatus == PaymentStatus.pending) {
        pending += net;
      }
    }

    return (total, pending, count);
  }

  double _resolveNetAmount(TransactionEntity txn) {
    if (txn.commission.netAmount > 0) {
      return txn.commission.netAmount;
    }
    final fee = txn.commission.platformFee > 0
        ? txn.commission.platformFee
        : (txn.amount * 0.05);
    final net = txn.amount - fee;
    return net > 0 ? net : 0.0;
  }
}
