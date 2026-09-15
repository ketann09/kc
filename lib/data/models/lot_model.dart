import 'dart:convert';

import '../../domain/entities/lot_entity.dart';
import 'matched_recycler_model.dart';

double _toDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class LotLocationModel extends LotLocationEntity {
  const LotLocationModel({
    super.address,
    super.latitude,
    super.longitude,
    super.pickupAddress,
    super.state,
    super.city,
  });

  factory LotLocationModel.fromEntity(LotLocationEntity entity) {
    return LotLocationModel(
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      pickupAddress: entity.pickupAddress,
      state: entity.state,
      city: entity.city,
    );
  }

  factory LotLocationModel.fromJson(Map<String, dynamic> json) {
    double? lat = _toDoubleNullable(json['latitude']);
    double? lng = _toDoubleNullable(json['longitude']);

    final coords = json['coordinates'];
    if (coords is Map) {
      final innerList = coords['coordinates'];
      if (innerList is List && innerList.length >= 2) {
        lng ??= _toDoubleNullable(innerList[0]);
        lat ??= _toDoubleNullable(innerList[1]);
      }
    } else if (coords is List && coords.length >= 2) {
      lng ??= _toDoubleNullable(coords[0]);
      lat ??= _toDoubleNullable(coords[1]);
    }

    return LotLocationModel(
      address: json['address']?.toString(),
      latitude: lat,
      longitude: lng,
      pickupAddress: json['pickupAddress']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
    };
  }
}

class LotMLPredictionModel extends LotMLPredictionEntity {
  const LotMLPredictionModel({
    super.predictedCategory,
    super.confidenceScore,
    super.predictedPrice,
    super.minPrice,
    super.maxPrice,
    super.matchLevel,
    super.unit,
  });

  factory LotMLPredictionModel.fromJson(Map<String, dynamic> json) {
    double? minP;
    double? maxP;
    if (json['priceRange'] is Map) {
      final pr = Map<String, dynamic>.from(json['priceRange'] as Map);
      minP = _toDoubleNullable(pr['min']);
      maxP = _toDoubleNullable(pr['max']);
    }

    return LotMLPredictionModel(
      predictedCategory: json['predictedCategory']?.toString(),
      confidenceScore: _toDoubleNullable(json['confidenceScore']),
      predictedPrice: _toDoubleNullable(json['predictedPrice']),
      minPrice: minP,
      maxPrice: maxP,
      matchLevel: json['matchLevel']?.toString(),
      unit: json['unit']?.toString(),
    );
  }
}

class LotModel extends LotEntity {
  const LotModel({
    required super.id,
    required super.collectorId,
    super.collectorName,
    super.collectorPhone,
    super.recyclerId,
    super.recyclerName,
    super.recyclerPhone,
    super.materialId,
    super.materialName,
    super.images,
    required super.estimatedWeight,
    super.actualWeight,
    required super.estimatedPrice,
    super.finalPrice,
    super.location,
    super.status,
    super.description,
    super.schedulePickup,
    super.matchedRecyclers,
    super.mlPrediction,
    super.createdAt,
    super.updatedAt,
  });

  factory LotModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> lotMap = json;
    if (json['data'] is Map) {
      final d = Map<String, dynamic>.from(json['data'] as Map);
      if (d['lot'] is Map) {
        lotMap = Map<String, dynamic>.from(d['lot'] as Map);
      } else {
        lotMap = d;
      }
    } else if (json['lot'] is Map) {
      lotMap = Map<String, dynamic>.from(json['lot'] as Map);
    }

    String cId = '';
    String? cName;
    String? cPhone;
    final colField = lotMap['collectorId'];
    if (colField is Map) {
      final colMap = Map<String, dynamic>.from(colField);
      cId = colMap['_id']?.toString() ?? colMap['id']?.toString() ?? '';
      cName = colMap['fullName']?.toString();
      cPhone = colMap['phoneNumber']?.toString();
    } else if (colField != null) {
      cId = colField.toString();
    }

    String? rId;
    String? rName;
    String? rPhone;
    final recField = lotMap['recyclerId'];
    if (recField is Map) {
      final recMap = Map<String, dynamic>.from(recField);
      rId = recMap['_id']?.toString() ?? recMap['id']?.toString();
      rName = recMap['fullName']?.toString();
      rPhone = recMap['phoneNumber']?.toString();
    } else if (recField != null) {
      rId = recField.toString();
    }

    String? mId;
    String? mName;
    final matField = lotMap['materialId'];
    if (matField is Map) {
      final matMap = Map<String, dynamic>.from(matField);
      mId = matMap['_id']?.toString() ?? matMap['id']?.toString();
      mName = matMap['name']?.toString();
    } else if (matField != null) {
      mId = matField.toString();
    }

    final imagesRaw = lotMap['images'];
    final imagesList = imagesRaw is List
        ? imagesRaw.map((e) => e.toString()).toList()
        : (imagesRaw is String && imagesRaw.isNotEmpty
              ? [imagesRaw]
              : <String>[]);

    final matchedRaw = lotMap['matchedRecyclers'];
    final matchedList = matchedRaw is List
        ? matchedRaw
              .whereType<Map>()
              .map(
                (e) =>
                    MatchedRecyclerModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <MatchedRecyclerModel>[];

    // Location parsing: handle both decoded Map and JSON-encoded String
    final locField = lotMap['location'];
    Map<String, dynamic> locationMap = {};
    if (locField is String && locField.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(locField);
        if (decoded is Map) {
          locationMap = Map<String, dynamic>.from(decoded);
        } else {
          locationMap = {'address': locField};
        }
      } catch (_) {
        locationMap = {'address': locField};
      }
    } else if (locField is Map) {
      locationMap = Map<String, dynamic>.from(locField);
    }

    final mlPredField = lotMap['mlPrediction'];
    final mlPredMap = mlPredField is Map
        ? Map<String, dynamic>.from(mlPredField)
        : null;

    final schedulePickupField = lotMap['schedulePickup'];
    final schedulePickupMap = schedulePickupField is Map
        ? Map<String, dynamic>.from(schedulePickupField)
        : null;

    return LotModel(
      id: lotMap['_id']?.toString() ?? lotMap['id']?.toString() ?? '',
      collectorId: cId,
      collectorName: cName,
      collectorPhone: cPhone,
      recyclerId: rId,
      recyclerName: rName,
      recyclerPhone: rPhone,
      materialId: mId,
      materialName: mName,
      images: imagesList,
      estimatedWeight: _toDouble(lotMap['estimatedWeight']),
      actualWeight: _toDoubleNullable(lotMap['actualWeight']),
      estimatedPrice: _toDouble(lotMap['estimatedPrice']),
      finalPrice: _toDoubleNullable(lotMap['finalPrice']),
      location: LotLocationModel.fromJson(locationMap),
      status: LotStatus.fromString(lotMap['status']?.toString()),
      description: lotMap['description']?.toString(),
      schedulePickup: schedulePickupMap,
      matchedRecyclers: matchedList,
      mlPrediction: mlPredMap != null
          ? LotMLPredictionModel.fromJson(mlPredMap)
          : null,
      createdAt: lotMap['createdAt'] != null
          ? DateTime.tryParse(lotMap['createdAt'].toString())
          : null,
      updatedAt: lotMap['updatedAt'] != null
          ? DateTime.tryParse(lotMap['updatedAt'].toString())
          : null,
    );
  }
}
