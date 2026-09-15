import '../../domain/entities/ml_classification_entity.dart';

double _toDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

class MLClassificationModel extends MLClassificationEntity {
  const MLClassificationModel({
    required super.category,
    required super.confidence,
    required super.confidencePercent,
  });

  factory MLClassificationModel.fromJson(Map<String, dynamic> json) {
    final map = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final conf = _toDouble(map['confidence'], 0.0);
    final confPercent = map['confidence_percent'] != null
        ? _toDouble(map['confidence_percent'])
        : (map['confidencePercent'] != null
              ? _toDouble(map['confidencePercent'])
              : (conf * 100));

    return MLClassificationModel(
      category: map['category']?.toString() ?? 'Other',
      confidence: conf,
      confidencePercent: confPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'confidence': confidence,
      'confidence_percent': confidencePercent,
    };
  }
}
