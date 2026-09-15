import 'package:equatable/equatable.dart';

class MaterialEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String? subCategory;
  final String? description;
  final List<String> images;
  final bool isRecyclable;
  final bool isHazardous;
  final int processingTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MaterialEntity({
    required this.id,
    required this.name,
    required this.category,
    this.subCategory,
    this.description,
    this.images = const [],
    this.isRecyclable = true,
    this.isHazardous = false,
    this.processingTime = 24,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    subCategory,
    description,
    images,
    isRecyclable,
    isHazardous,
    processingTime,
    createdAt,
    updatedAt,
  ];
}
