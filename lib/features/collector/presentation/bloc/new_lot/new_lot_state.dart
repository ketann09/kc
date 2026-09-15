import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/lot_entity.dart';
import '../../../../../domain/entities/ml_classification_entity.dart';
import '../../../../../domain/entities/ml_price_entity.dart';

enum NewLotStatus {
  initial,
  classifying,
  classified,
  pricing,
  priced,
  submitting,
  success,
  failure,
}

enum NewLotErrorType { none, classification, pricing, submission }

class NewLotState extends Equatable {
  final NewLotStatus status;
  final NewLotErrorType errorType;
  final String? errorMessage;
  final String? imagePath;
  final MLClassificationEntity? classification;
  final String? category;
  final double weightKg;
  final int quantity;
  final MLPriceEntity? priceEstimate;
  final LotEntity? createdLot;

  const NewLotState({
    this.status = NewLotStatus.initial,
    this.errorType = NewLotErrorType.none,
    this.errorMessage,
    this.imagePath,
    this.classification,
    this.category,
    this.weightKg = 1.0,
    this.quantity = 1,
    this.priceEstimate,
    this.createdLot,
  });

  NewLotState copyWith({
    NewLotStatus? status,
    NewLotErrorType? errorType,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? imagePath,
    MLClassificationEntity? classification,
    String? category,
    double? weightKg,
    int? quantity,
    MLPriceEntity? priceEstimate,
    LotEntity? createdLot,
  }) {
    return NewLotState(
      status: status ?? this.status,
      errorType: errorType ?? this.errorType,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      imagePath: imagePath ?? this.imagePath,
      classification: classification ?? this.classification,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      quantity: quantity ?? this.quantity,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      createdLot: createdLot ?? this.createdLot,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorType,
    errorMessage,
    imagePath,
    classification,
    category,
    weightKg,
    quantity,
    priceEstimate,
    createdLot,
  ];
}
