import 'package:equatable/equatable.dart';

import '../../../../../core/network/api_exception.dart';
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
  final bool isManualCategory;
  final double weightKg;
  final int quantity;
  final MLPriceEntity? priceEstimate;
  final LotEntity? createdLot;
  final ApiException? lastException;

  const NewLotState({
    this.status = NewLotStatus.initial,
    this.errorType = NewLotErrorType.none,
    this.errorMessage,
    this.imagePath,
    this.classification,
    this.category,
    this.isManualCategory = false,
    this.weightKg = 1.0,
    this.quantity = 1,
    this.priceEstimate,
    this.createdLot,
    this.lastException,
  });

  NewLotState copyWith({
    NewLotStatus? status,
    NewLotErrorType? errorType,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? imagePath,
    MLClassificationEntity? classification,
    bool clearClassification = false,
    String? category,
    bool clearCategory = false,
    bool? isManualCategory,
    double? weightKg,
    int? quantity,
    MLPriceEntity? priceEstimate,
    bool clearPriceEstimate = false,
    LotEntity? createdLot,
    ApiException? lastException,
    bool clearLastException = false,
  }) {
    return NewLotState(
      status: status ?? this.status,
      errorType: errorType ?? this.errorType,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      imagePath: imagePath ?? this.imagePath,
      classification: clearClassification
          ? null
          : (classification ?? this.classification),
      category: clearCategory ? null : (category ?? this.category),
      isManualCategory: isManualCategory ?? this.isManualCategory,
      weightKg: weightKg ?? this.weightKg,
      quantity: quantity ?? this.quantity,
      priceEstimate: clearPriceEstimate
          ? null
          : (priceEstimate ?? this.priceEstimate),
      createdLot: createdLot ?? this.createdLot,
      lastException: clearLastException
          ? null
          : (lastException ?? this.lastException),
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
    isManualCategory,
    weightKg,
    quantity,
    priceEstimate,
    createdLot,
  ];
}
