import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/transaction_entity.dart';

abstract class TransactionDetailsState extends Equatable {
  const TransactionDetailsState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailsInitial extends TransactionDetailsState {
  const TransactionDetailsInitial();
}

class TransactionDetailsLoading extends TransactionDetailsState {
  const TransactionDetailsLoading();
}

class TransactionDetailsLoaded extends TransactionDetailsState {
  final TransactionEntity transaction;
  final bool isSubmittingHandover;
  final bool isSubmittingPayment;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;
  final ApiException? lastActionException;

  const TransactionDetailsLoaded(
    this.transaction, {
    this.isSubmittingHandover = false,
    this.isSubmittingPayment = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
    this.lastActionException,
  });

  TransactionDetailsLoaded copyWith({
    TransactionEntity? transaction,
    bool? isSubmittingHandover,
    bool? isSubmittingPayment,
    String? actionSuccessMessage,
    String? actionErrorMessage,
    ApiException? lastActionException,
    bool clearLastActionException = false,
  }) {
    return TransactionDetailsLoaded(
      transaction ?? this.transaction,
      isSubmittingHandover: isSubmittingHandover ?? this.isSubmittingHandover,
      isSubmittingPayment: isSubmittingPayment ?? this.isSubmittingPayment,
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
      lastActionException: clearLastActionException
          ? null
          : (lastActionException ?? this.lastActionException),
    );
  }

  @override
  List<Object?> get props => [
    transaction,
    isSubmittingHandover,
    isSubmittingPayment,
    actionSuccessMessage,
    actionErrorMessage,
  ];
}

class TransactionDetailsFailure extends TransactionDetailsState {
  final String message;
  final ApiException? lastException;

  const TransactionDetailsFailure(this.message, {this.lastException});

  @override
  List<Object?> get props => [message];
}
