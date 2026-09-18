import 'package:equatable/equatable.dart';

abstract class TransactionDetailsEvent extends Equatable {
  const TransactionDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactionDetailsEvent extends TransactionDetailsEvent {
  final String transactionId;

  const FetchTransactionDetailsEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CreateTransactionEvent extends TransactionDetailsEvent {
  final String lotId;
  final String paymentMethod;
  final double amount;
  final double? actualWeight;
  final double? estimatedWeight;
  final String? notes;

  const CreateTransactionEvent({
    required this.lotId,
    required this.paymentMethod,
    required this.amount,
    this.actualWeight,
    this.estimatedWeight,
    this.notes,
  });

  @override
  List<Object?> get props => [
    lotId,
    paymentMethod,
    amount,
    actualWeight,
    estimatedWeight,
    notes,
  ];
}

class UpdateHandoverEvent extends TransactionDetailsEvent {
  final String transactionId;
  final List<String>? handoverPhotos;
  final double? latitude;
  final double? longitude;
  final String? receivedBy;
  final String? verifiedBy;

  const UpdateHandoverEvent({
    required this.transactionId,
    this.handoverPhotos,
    this.latitude,
    this.longitude,
    this.receivedBy,
    this.verifiedBy,
  });

  @override
  List<Object?> get props => [
    transactionId,
    handoverPhotos,
    latitude,
    longitude,
    receivedBy,
    verifiedBy,
  ];
}

class UpdatePaymentEvent extends TransactionDetailsEvent {
  final String transactionId;
  final String paymentStatus;
  final String? paymentTransactionId;
  final String? receiptUrl;

  const UpdatePaymentEvent({
    required this.transactionId,
    required this.paymentStatus,
    this.paymentTransactionId,
    this.receiptUrl,
  });

  @override
  List<Object?> get props => [
    transactionId,
    paymentStatus,
    paymentTransactionId,
    receiptUrl,
  ];
}

class ResetTransactionActionEvent extends TransactionDetailsEvent {
  const ResetTransactionActionEvent();
}
