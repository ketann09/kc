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

  const CollectorTransactionsLoaded({
    required this.transactions,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.completedCount,
    this.statusFilter,
  });

  CollectorTransactionsLoaded copyWith({
    List<TransactionEntity>? transactions,
    double? totalEarnings,
    double? pendingEarnings,
    int? completedCount,
    String? statusFilter,
  }) {
    return CollectorTransactionsLoaded(
      transactions: transactions ?? this.transactions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      completedCount: completedCount ?? this.completedCount,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    totalEarnings,
    pendingEarnings,
    completedCount,
    statusFilter,
  ];
}

class CollectorTransactionsFailure extends CollectorTransactionsState {
  final String message;

  const CollectorTransactionsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
