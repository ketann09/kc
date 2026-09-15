import '../../domain/entities/ml_price_entity.dart';

double _toDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

class MLPriceModel extends MLPriceEntity {
  const MLPriceModel({
    required super.category,
    required super.recommendedRateInr,
    super.unit = 'per_kg',
    required super.estimatedValueInr,
    required super.estimatedValueMinInr,
    required super.estimatedValueMaxInr,
    super.matchLevel,
  });

  factory MLPriceModel.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final pricing = root['pricing'] is Map
        ? Map<String, dynamic>.from(root['pricing'] as Map)
        : root;

    final rate = pricing['recommended_rate_inr'] != null
        ? _toDouble(pricing['recommended_rate_inr'])
        : _toDouble(pricing['recommendedRateInr']);

    final estValue = pricing['estimated_value_inr'] != null
        ? _toDouble(pricing['estimated_value_inr'])
        : _toDouble(pricing['estimatedValueInr']);

    final minVal = pricing['estimated_value_min_inr'] != null
        ? _toDouble(pricing['estimated_value_min_inr'])
        : (pricing['estimatedValueMinInr'] != null
              ? _toDouble(pricing['estimatedValueMinInr'])
              : (estValue * 0.95));

    final maxVal = pricing['estimated_value_max_inr'] != null
        ? _toDouble(pricing['estimated_value_max_inr'])
        : (pricing['estimatedValueMaxInr'] != null
              ? _toDouble(pricing['estimatedValueMaxInr'])
              : (estValue * 1.05));

    return MLPriceModel(
      category: pricing['category']?.toString() ?? '',
      recommendedRateInr: rate,
      unit: pricing['unit']?.toString() ?? 'per_kg',
      estimatedValueInr: estValue,
      estimatedValueMinInr: minVal,
      estimatedValueMaxInr: maxVal,
      matchLevel:
          pricing['match_level']?.toString() ??
          pricing['matchLevel']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'recommended_rate_inr': recommendedRateInr,
      'unit': unit,
      'estimated_value_inr': estimatedValueInr,
      'estimated_value_min_inr': estimatedValueMinInr,
      'estimated_value_max_inr': estimatedValueMaxInr,
      'match_level': matchLevel,
    };
  }
}
