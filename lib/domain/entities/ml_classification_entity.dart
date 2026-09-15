import 'package:equatable/equatable.dart';

class MLClassificationEntity extends Equatable {
  final String category;
  final double confidence;
  final double confidencePercent;

  const MLClassificationEntity({
    required this.category,
    required this.confidence,
    required this.confidencePercent,
  });

  @override
  List<Object?> get props => [category, confidence, confidencePercent];
}
