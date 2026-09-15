import 'package:equatable/equatable.dart';

class MLPriceEntity extends Equatable {
  final String category;
  final double recommendedRateInr;
  final String unit;
  final double estimatedValueInr;
  final double estimatedValueMinInr;
  final double estimatedValueMaxInr;
  final String? matchLevel;

  const MLPriceEntity({
    required this.category,
    required this.recommendedRateInr,
    this.unit = 'per_kg',
    required this.estimatedValueInr,
    required this.estimatedValueMinInr,
    required this.estimatedValueMaxInr,
    this.matchLevel,
  });

  @override
  List<Object?> get props => [
    category,
    recommendedRateInr,
    unit,
    estimatedValueInr,
    estimatedValueMinInr,
    estimatedValueMaxInr,
    matchLevel,
  ];
}
