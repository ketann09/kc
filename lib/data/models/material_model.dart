import '../../domain/entities/material_entity.dart';

int _toInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  final s = value.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return defaultValue;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return [];
}

class MaterialModel extends MaterialEntity {
  const MaterialModel({
    required super.id,
    required super.name,
    required super.category,
    super.subCategory,
    super.description,
    super.images,
    super.isRecyclable,
    super.isHazardous,
    super.processingTime,
    super.createdAt,
    super.updatedAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      subCategory: json['subCategory']?.toString(),
      description: json['description']?.toString(),
      images: _parseStringList(json['images']),
      isRecyclable: _parseBool(json['isRecyclable'], defaultValue: true),
      isHazardous: _parseBool(json['isHazardous'], defaultValue: false),
      processingTime: _toInt(json['processingTime'], 24),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (description != null) 'description': description,
      'images': images,
      'isRecyclable': isRecyclable,
      'isHazardous': isHazardous,
      'processingTime': processingTime,
    };
  }
}
