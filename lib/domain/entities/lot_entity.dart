import 'package:equatable/equatable.dart';

import 'matched_recycler_entity.dart';

enum LotStatus {
  pending('pending'),
  accepted('accepted'),
  picked('picked'),
  delivered('delivered'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const LotStatus(this.value);

  static LotStatus fromString(String? val) {
    if (val == null) return LotStatus.pending;
    switch (val.toLowerCase().trim()) {
      case 'accepted':
        return LotStatus.accepted;
      case 'picked':
        return LotStatus.picked;
      case 'delivered':
        return LotStatus.delivered;
      case 'completed':
        return LotStatus.completed;
      case 'cancelled':
        return LotStatus.cancelled;
      case 'pending':
      default:
        return LotStatus.pending;
    }
  }
}

class LotLocationEntity extends Equatable {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? pickupAddress;
  final String? state;
  final String? city;

  const LotLocationEntity({
    this.address,
    this.latitude,
    this.longitude,
    this.pickupAddress,
    this.state,
    this.city,
  });

  @override
  List<Object?> get props => [
    address,
    latitude,
    longitude,
    pickupAddress,
    state,
    city,
  ];
}

class LotMLPredictionEntity extends Equatable {
  final String? predictedCategory;
  final double? confidenceScore;
  final double? predictedPrice;
  final double? minPrice;
  final double? maxPrice;
  final String? matchLevel;
  final String? unit;

  const LotMLPredictionEntity({
    this.predictedCategory,
    this.confidenceScore,
    this.predictedPrice,
    this.minPrice,
    this.maxPrice,
    this.matchLevel,
    this.unit,
  });

  @override
  List<Object?> get props => [
    predictedCategory,
    confidenceScore,
    predictedPrice,
    minPrice,
    maxPrice,
    matchLevel,
    unit,
  ];
}

class LotEntity extends Equatable {
  final String id;
  final String collectorId;
  final String? collectorName;
  final String? collectorPhone;
  final String? recyclerId;
  final String? recyclerName;
  final String? recyclerPhone;
  final String? materialId;
  final String? materialName;
  final List<String> images;
  final double estimatedWeight;
  final double? actualWeight;
  final double estimatedPrice;
  final double? finalPrice;
  final LotLocationEntity location;
  final LotStatus status;
  final String? description;
  final Map<String, dynamic>? schedulePickup;
  final List<MatchedRecyclerEntity> matchedRecyclers;
  final LotMLPredictionEntity? mlPrediction;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LotEntity({
    required this.id,
    required this.collectorId,
    this.collectorName,
    this.collectorPhone,
    this.recyclerId,
    this.recyclerName,
    this.recyclerPhone,
    this.materialId,
    this.materialName,
    this.images = const [],
    required this.estimatedWeight,
    this.actualWeight,
    required this.estimatedPrice,
    this.finalPrice,
    this.location = const LotLocationEntity(),
    this.status = LotStatus.pending,
    this.description,
    this.schedulePickup,
    this.matchedRecyclers = const [],
    this.mlPrediction,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    collectorId,
    collectorName,
    collectorPhone,
    recyclerId,
    recyclerName,
    recyclerPhone,
    materialId,
    materialName,
    images,
    estimatedWeight,
    actualWeight,
    estimatedPrice,
    finalPrice,
    location,
    status,
    description,
    schedulePickup,
    matchedRecyclers,
    mlPrediction,
    createdAt,
    updatedAt,
  ];
}

class CreateLotParams {
  final List<String> imagePaths;
  final double estimatedWeight;
  final LotLocationEntity location;
  final double? estimatedPrice;
  final String? category;
  final String? subCategory;
  final String? description;
  final String? materialId;
  final String? state;
  final String? city;
  final int quantity;
  final String? confirmCategory;
  final Map<String, dynamic>? schedulePickup;

  const CreateLotParams({
    required this.imagePaths,
    required this.estimatedWeight,
    required this.location,
    this.estimatedPrice,
    this.category,
    this.subCategory,
    this.description,
    this.materialId,
    this.state,
    this.city,
    this.quantity = 1,
    this.confirmCategory = 'true',
    this.schedulePickup,
  });
}
