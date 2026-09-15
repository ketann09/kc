import 'package:equatable/equatable.dart';

import 'ml_classification_entity.dart';
import 'ml_price_entity.dart';

class MLPredictAndPriceResultEntity extends Equatable {
  final MLClassificationEntity? classification;
  final MLPriceEntity? pricing;

  const MLPredictAndPriceResultEntity({this.classification, this.pricing});

  @override
  List<Object?> get props => [classification, pricing];
}
