import '../../domain/entities/matched_recycler_entity.dart';

double _toDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

num _toNum(dynamic value, [num defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? defaultValue;
}

class MatchedRecyclerModel extends MatchedRecyclerEntity {
  const MatchedRecyclerModel({
    required super.recyclerId,
    super.recyclerName,
    super.phoneNumber,
    super.address,
    required super.price,
    super.estimatedTotal,
    super.distance,
    super.score,
    super.breakdown,
    super.priceId,
    super.matchedAt,
  });

  factory MatchedRecyclerModel.fromJson(Map<String, dynamic> json) {
    String id = '';
    String? name;
    String? phone;
    String? addrStr;

    final recField = json['recyclerId'];
    if (recField is Map) {
      final recMap = Map<String, dynamic>.from(recField);
      id = recMap['_id']?.toString() ?? recMap['id']?.toString() ?? '';
      name = recMap['fullName']?.toString();
      phone = recMap['phoneNumber']?.toString();
      if (recMap['address'] is Map) {
        final a = Map<String, dynamic>.from(recMap['address'] as Map);
        addrStr = a['street'] != null
            ? '${a['street']}, ${a['city'] ?? ''}'
            : a['city']?.toString();
      } else if (recMap['address'] != null) {
        addrStr = recMap['address'].toString();
      }
    } else if (recField != null) {
      id = recField.toString();
    }

    if (name == null && json['recyclerName'] != null) {
      name = json['recyclerName'].toString();
    }
    if (phone == null && json['phoneNumber'] != null) {
      phone = json['phoneNumber'].toString();
    }
    if (addrStr == null && json['address'] != null) {
      if (json['address'] is Map) {
        final a = Map<String, dynamic>.from(json['address'] as Map);
        addrStr = a['street'] != null
            ? '${a['street']}, ${a['city'] ?? ''}'
            : a['city']?.toString();
      } else {
        addrStr = json['address'].toString();
      }
    }

    MatchedRecyclerScoreBreakdown? bd;
    if (json['breakdown'] is Map) {
      final b = Map<String, dynamic>.from(json['breakdown'] as Map);
      bd = MatchedRecyclerScoreBreakdown(
        price: _toNum(b['price']),
        distance: _toNum(b['distance']),
        rating: _toNum(b['rating']),
        availability: _toNum(b['availability']),
      );
    }

    return MatchedRecyclerModel(
      recyclerId: id,
      recyclerName: name,
      phoneNumber: phone,
      address: addrStr,
      price: _toDouble(json['price']),
      estimatedTotal: _toDouble(json['estimatedTotal']),
      distance: _toDouble(json['distance']),
      score: _toDouble(json['score']),
      breakdown: bd,
      priceId: json['priceId']?.toString(),
      matchedAt: json['matchedAt'] != null
          ? DateTime.tryParse(json['matchedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recyclerId': recyclerId,
      if (recyclerName != null) 'recyclerName': recyclerName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      'price': price,
      'estimatedTotal': estimatedTotal,
      'distance': distance,
      'score': score,
      if (priceId != null) 'priceId': priceId,
      if (matchedAt != null) 'matchedAt': matchedAt!.toIso8601String(),
    };
  }
}
