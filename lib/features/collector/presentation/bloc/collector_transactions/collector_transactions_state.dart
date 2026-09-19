import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/transaction_entity.dart';

abstract class CollectorTransactionsState extends Equatable {
  const CollectorTransactionsState();

  @override
  List<Object?> get props => [];
}

class CollectorTransactionsInitial extends CollectorTransactionsState {
  const CollectorTransactionsInitial();
}

class CollectorTransactionsLoading extends CollectorTransactionsState {
  const CollectorTransactionsLoading();
}

class CollectorTransactionsLoaded extends CollectorTransactionsState {
  final List<TransactionEntity> transactions;
  final double totalEarnings;
  final double pendingEarnings;
  final int completedCount;
  final String? statusFilter;
  final bool isOffline;
  final bool isRefreshing;
  final DateTime? cachedAt;
  final String? refreshError;

  const CollectorTransactionsLoaded({
    required this.transactions,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.completedCount,
    this.statusFilter,
    this.isOffline = false,
    this.isRefreshing = false,
    this.cachedAt,
    this.refreshError,
  });

  CollectorTransactionsLoaded copyWith({
    List<TransactionEntity>? transactions,
    double? totalEarnings,
    double? pendingEarnings,
    int? completedCount,
    String? statusFilter,
    bool? isOffline,
    bool? isRefreshing,
    DateTime? cachedAt,
    String? refreshError,
  }) {
    return CollectorTransactionsLoaded(
      transactions: transactions ?? this.transactions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      completedCount: completedCount ?? this.completedCount,
      statusFilter: statusFilter ?? this.statusFilter,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
      refreshError: refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    totalEarnings,
    pendingEarnings,
    completedCount,
    statusFilter,
    isOffline,
    isRefreshing,
    cachedAt,
    refreshError,
  ];
}

class CollectorTransactionsFailure extends CollectorTransactionsState {
  final String message;
  final bool isOffline;

  const CollectorTransactionsFailure(this.message, {this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}
