import 'package:equatable/equatable.dart';

enum PaymentMethod {
  cash('cash', 'नकद'),
  upi('upi', 'यूपीआई'),
  wallet('wallet', 'वॉलेट'),
  bankTransfer('bank_transfer', 'बैंक ट्रांसफर');

  final String value;
  final String hindiLabel;
  const PaymentMethod(this.value, this.hindiLabel);

  static PaymentMethod fromString(String? val) {
    if (val == null) return PaymentMethod.cash;
    switch (val.toLowerCase().trim()) {
      case 'upi':
        return PaymentMethod.upi;
      case 'wallet':
        return PaymentMethod.wallet;
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'cash':
      default:
        return PaymentMethod.cash;
    }
  }
}

enum PaymentStatus {
  pending('pending', 'लंबित'),
  completed('completed', 'पूर्ण'),
  failed('failed', 'विफल');

  final String value;
  final String hindiLabel;
  const PaymentStatus(this.value, this.hindiLabel);

  static PaymentStatus fromString(String? val) {
    if (val == null) return PaymentStatus.pending;
    switch (val.toLowerCase().trim()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

enum TransactionStatus {
  initiated('initiated', 'शुरू किया गया'),
  inProgress('in_progress', 'प्रगति में'),
  completed('completed', 'पूर्ण'),
  failed('failed', 'विफल'),
  refunded('refunded', 'वापस किया गया');

  final String value;
  final String hindiLabel;
  const TransactionStatus(this.value, this.hindiLabel);

  static TransactionStatus fromString(String? val) {
    if (val == null) return TransactionStatus.initiated;
    switch (val.toLowerCase().trim()) {
      case 'in_progress':
      case 'inprogress':
        return TransactionStatus.inProgress;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'refunded':
        return TransactionStatus.refunded;
      case 'initiated':
      default:
        return TransactionStatus.initiated;
    }
  }
}

class TransactionWeightDetailsEntity extends Equatable {
  final double estimatedWeight;
  final double actualWeight;
  final double weightDifference;
  final String weightUnit;

  const TransactionWeightDetailsEntity({
    this.estimatedWeight = 0.0,
    this.actualWeight = 0.0,
    this.weightDifference = 0.0,
    this.weightUnit = 'kg',
  });

  @override
  List<Object?> get props => [
    estimatedWeight,
    actualWeight,
    weightDifference,
    weightUnit,
  ];
}

class TransactionCommissionEntity extends Equatable {
  final double platformFee;
  final double commissionRate;
  final double netAmount;

  const TransactionCommissionEntity({
    this.platformFee = 0.0,
    this.commissionRate = 5.0,
    this.netAmount = 0.0,
  });

  @override
  List<Object?> get props => [platformFee, commissionRate, netAmount];
}

class TransactionHandoverDetailsEntity extends Equatable {
  final List<String> handoverPhotos;
  final double? latitude;
  final double? longitude;
  final String? handoverSignature;
  final DateTime? handoverTime;
  final String? receivedBy;
  final String? verifiedBy;

  const TransactionHandoverDetailsEntity({
    this.handoverPhotos = const [],
    this.latitude,
    this.longitude,
    this.handoverSignature,
    this.handoverTime,
    this.receivedBy,
    this.verifiedBy,
  });

  bool get isCompleted =>
      handoverTime != null ||
      (receivedBy != null && receivedBy!.isNotEmpty) ||
      (verifiedBy != null && verifiedBy!.isNotEmpty);

  @override
  List<Object?> get props => [
    handoverPhotos,
    latitude,
    longitude,
    handoverSignature,
    handoverTime,
    receivedBy,
    verifiedBy,
  ];
}

class TransactionPaymentDetailsEntity extends Equatable {
  final String? transactionId;
  final String? paymentGateway;
  final String? upiId;
  final String? bankReference;
  final String? receiptUrl;

  const TransactionPaymentDetailsEntity({
    this.transactionId,
    this.paymentGateway,
    this.upiId,
    this.bankReference,
    this.receiptUrl,
  });

  @override
  List<Object?> get props => [
    transactionId,
    paymentGateway,
    upiId,
    bankReference,
    receiptUrl,
  ];
}

class TransactionEntity extends Equatable {
  final String id;
  final String lotId;
  final String collectorId;
  final String? collectorName;
  final String? collectorPhone;
  final String? collectorAddress;
  final String recyclerId;
  final String? recyclerName;
  final String? recyclerPhone;
  final String? recyclerAddress;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final TransactionPaymentDetailsEntity paymentDetails;
  final TransactionHandoverDetailsEntity handoverDetails;
  final TransactionWeightDetailsEntity weightDetails;
  final TransactionCommissionEntity commission;
  final TransactionStatus status;
  final String? notes;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? lotStatus;
  final double? lotEstimatedWeight;

  const TransactionEntity({
    required this.id,
    required this.lotId,
    required this.collectorId,
    this.collectorName,
    this.collectorPhone,
    this.collectorAddress,
    required this.recyclerId,
    this.recyclerName,
    this.recyclerPhone,
    this.recyclerAddress,
    required this.amount,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentDetails = const TransactionPaymentDetailsEntity(),
    this.handoverDetails = const TransactionHandoverDetailsEntity(),
    this.weightDetails = const TransactionWeightDetailsEntity(),
    this.commission = const TransactionCommissionEntity(),
    this.status = TransactionStatus.initiated,
    this.notes,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.lotStatus,
    this.lotEstimatedWeight,
  });

  TransactionEntity copyWith({
    String? id,
    String? lotId,
    String? collectorId,
    String? collectorName,
    String? collectorPhone,
    String? collectorAddress,
    String? recyclerId,
    String? recyclerName,
    String? recyclerPhone,
    String? recyclerAddress,
    double? amount,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    TransactionPaymentDetailsEntity? paymentDetails,
    TransactionHandoverDetailsEntity? handoverDetails,
    TransactionWeightDetailsEntity? weightDetails,
    TransactionCommissionEntity? commission,
    TransactionStatus? status,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lotStatus,
    double? lotEstimatedWeight,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      collectorPhone: collectorPhone ?? this.collectorPhone,
      collectorAddress: collectorAddress ?? this.collectorAddress,
      recyclerId: recyclerId ?? this.recyclerId,
      recyclerName: recyclerName ?? this.recyclerName,
      recyclerPhone: recyclerPhone ?? this.recyclerPhone,
      recyclerAddress: recyclerAddress ?? this.recyclerAddress,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      handoverDetails: handoverDetails ?? this.handoverDetails,
      weightDetails: weightDetails ?? this.weightDetails,
      commission: commission ?? this.commission,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lotStatus: lotStatus ?? this.lotStatus,
      lotEstimatedWeight: lotEstimatedWeight ?? this.lotEstimatedWeight,
    );
  }

  @override
  List<Object?> get props => [
    id,
    lotId,
    collectorId,
    collectorName,
    collectorPhone,
    collectorAddress,
    recyclerId,
    recyclerName,
    recyclerPhone,
    recyclerAddress,
    amount,
    paymentMethod,
    paymentStatus,
    paymentDetails,
    handoverDetails,
    weightDetails,
    commission,
    status,
    notes,
    completedAt,
    createdAt,
    updatedAt,
    lotStatus,
    lotEstimatedWeight,
  ];
}
