import '../../domain/entities/transaction_entity.dart';

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

String? _extractAddress(dynamic addressVal) {
  if (addressVal == null) return null;
  if (addressVal is String) return addressVal;
  if (addressVal is Map) {
    final street = addressVal['street'] ?? addressVal['address'] ?? '';
    final city = addressVal['city'] ?? '';
    final state = addressVal['state'] ?? '';
    final pincode = addressVal['pincode'] ?? '';
    final parts = [
      street,
      city,
      state,
      pincode,
    ].where((p) => p.toString().trim().isNotEmpty).join(', ');
    return parts.isNotEmpty ? parts : null;
  }
  return addressVal.toString();
}

class TransactionWeightDetailsModel extends TransactionWeightDetailsEntity {
  const TransactionWeightDetailsModel({
    super.estimatedWeight = 0.0,
    super.actualWeight = 0.0,
    super.weightDifference = 0.0,
    super.weightUnit = 'kg',
  });

  factory TransactionWeightDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransactionWeightDetailsModel();
    return TransactionWeightDetailsModel(
      estimatedWeight: _toDouble(json['estimatedWeight']),
      actualWeight: _toDouble(json['actualWeight']),
      weightDifference: _toDouble(json['weightDifference']),
      weightUnit: json['weightUnit']?.toString() ?? 'kg',
    );
  }

  factory TransactionWeightDetailsModel.fromEntity(
    TransactionWeightDetailsEntity entity,
  ) {
    return TransactionWeightDetailsModel(
      estimatedWeight: entity.estimatedWeight,
      actualWeight: entity.actualWeight,
      weightDifference: entity.weightDifference,
      weightUnit: entity.weightUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedWeight': estimatedWeight,
      'actualWeight': actualWeight,
      'weightDifference': weightDifference,
      'weightUnit': weightUnit,
    };
  }
}

class TransactionCommissionModel extends TransactionCommissionEntity {
  const TransactionCommissionModel({
    super.platformFee = 0.0,
    super.commissionRate = 5.0,
    super.netAmount = 0.0,
  });

  factory TransactionCommissionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransactionCommissionModel();
    return TransactionCommissionModel(
      platformFee: _toDouble(json['platformFee']),
      commissionRate: _toDouble(json['commissionRate'], 5.0),
      netAmount: _toDouble(json['netAmount']),
    );
  }

  factory TransactionCommissionModel.fromEntity(
    TransactionCommissionEntity entity,
  ) {
    return TransactionCommissionModel(
      platformFee: entity.platformFee,
      commissionRate: entity.commissionRate,
      netAmount: entity.netAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platformFee': platformFee,
      'commissionRate': commissionRate,
      'netAmount': netAmount,
    };
  }
}

class TransactionHandoverDetailsModel extends TransactionHandoverDetailsEntity {
  const TransactionHandoverDetailsModel({
    super.handoverPhotos = const [],
    super.latitude,
    super.longitude,
    super.handoverSignature,
    super.handoverTime,
    super.receivedBy,
    super.verifiedBy,
  });

  factory TransactionHandoverDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransactionHandoverDetailsModel();

    List<String> photos = [];
    if (json['handoverPhotos'] is List) {
      photos = (json['handoverPhotos'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    double? lat;
    double? lng;
    final gps = json['handoverGPS'];
    if (gps is Map) {
      lat = _toDoubleNullable(gps['latitude']);
      lng = _toDoubleNullable(gps['longitude']);
    } else if (gps is List && gps.length >= 2) {
      lng = _toDoubleNullable(gps[0]);
      lat = _toDoubleNullable(gps[1]);
    }

    DateTime? time;
    if (json['handoverTime'] != null) {
      time = DateTime.tryParse(json['handoverTime'].toString());
    }

    return TransactionHandoverDetailsModel(
      handoverPhotos: photos,
      latitude: lat,
      longitude: lng,
      handoverSignature: json['handoverSignature']?.toString(),
      handoverTime: time,
      receivedBy: json['receivedBy']?.toString(),
      verifiedBy: json['verifiedBy']?.toString(),
    );
  }

  factory TransactionHandoverDetailsModel.fromEntity(
    TransactionHandoverDetailsEntity entity,
  ) {
    return TransactionHandoverDetailsModel(
      handoverPhotos: entity.handoverPhotos,
      latitude: entity.latitude,
      longitude: entity.longitude,
      handoverSignature: entity.handoverSignature,
      handoverTime: entity.handoverTime,
      receivedBy: entity.receivedBy,
      verifiedBy: entity.verifiedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'handoverPhotos': handoverPhotos,
      if (latitude != null || longitude != null)
        'handoverGPS': {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      if (handoverSignature != null) 'handoverSignature': handoverSignature,
      if (handoverTime != null) 'handoverTime': handoverTime!.toIso8601String(),
      if (receivedBy != null) 'receivedBy': receivedBy,
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
    };
  }
}

class TransactionPaymentDetailsModel extends TransactionPaymentDetailsEntity {
  const TransactionPaymentDetailsModel({
    super.transactionId,
    super.paymentGateway,
    super.upiId,
    super.bankReference,
    super.receiptUrl,
  });

  factory TransactionPaymentDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransactionPaymentDetailsModel();
    return TransactionPaymentDetailsModel(
      transactionId: json['transactionId']?.toString(),
      paymentGateway: json['paymentGateway']?.toString(),
      upiId: json['upiId']?.toString(),
      bankReference: json['bankReference']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
    );
  }

  factory TransactionPaymentDetailsModel.fromEntity(
    TransactionPaymentDetailsEntity entity,
  ) {
    return TransactionPaymentDetailsModel(
      transactionId: entity.transactionId,
      paymentGateway: entity.paymentGateway,
      upiId: entity.upiId,
      bankReference: entity.bankReference,
      receiptUrl: entity.receiptUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (transactionId != null) 'transactionId': transactionId,
      if (paymentGateway != null) 'paymentGateway': paymentGateway,
      if (upiId != null) 'upiId': upiId,
      if (bankReference != null) 'bankReference': bankReference,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
    };
  }
}

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.lotId,
    required super.collectorId,
    super.collectorName,
    super.collectorPhone,
    super.collectorAddress,
    required super.recyclerId,
    super.recyclerName,
    super.recyclerPhone,
    super.recyclerAddress,
    required super.amount,
    super.paymentMethod,
    super.paymentStatus,
    super.paymentDetails,
    super.handoverDetails,
    super.weightDetails,
    super.commission,
    super.status,
    super.notes,
    super.completedAt,
    super.createdAt,
    super.updatedAt,
    super.lotStatus,
    super.lotEstimatedWeight,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';

    // Collector parsing (can be string ID or populated object)
    String collectorId = '';
    String? collectorName;
    String? collectorPhone;
    String? collectorAddress;
    final rawCollector = json['collectorId'];
    if (rawCollector is Map) {
      collectorId = rawCollector['_id']?.toString() ?? '';
      collectorName =
          rawCollector['fullName']?.toString() ??
          rawCollector['name']?.toString();
      collectorPhone =
          rawCollector['phoneNumber']?.toString() ??
          rawCollector['phone']?.toString();
      collectorAddress = _extractAddress(rawCollector['address']);
    } else if (rawCollector != null) {
      collectorId = rawCollector.toString();
    }

    // Recycler parsing (can be string ID or populated object)
    String recyclerId = '';
    String? recyclerName;
    String? recyclerPhone;
    String? recyclerAddress;
    final rawRecycler = json['recyclerId'];
    if (rawRecycler is Map) {
      recyclerId = rawRecycler['_id']?.toString() ?? '';
      recyclerName =
          rawRecycler['fullName']?.toString() ??
          rawRecycler['name']?.toString();
      recyclerPhone =
          rawRecycler['phoneNumber']?.toString() ??
          rawRecycler['phone']?.toString();
      recyclerAddress = _extractAddress(rawRecycler['address']);
    } else if (rawRecycler != null) {
      recyclerId = rawRecycler.toString();
    }

    // Lot parsing (can be string ID or populated object)
    String lotId = '';
    String? lotStatus;
    double? lotEstimatedWeight;
    final rawLot = json['lotId'];
    if (rawLot is Map) {
      lotId = rawLot['_id']?.toString() ?? '';
      lotStatus = rawLot['status']?.toString();
      lotEstimatedWeight = _toDoubleNullable(rawLot['estimatedWeight']);
    } else if (rawLot != null) {
      lotId = rawLot.toString();
    }

    // Sub-models
    final weightDetails = json['weightDetails'] is Map
        ? TransactionWeightDetailsModel.fromJson(
            Map<String, dynamic>.from(json['weightDetails'] as Map),
          )
        : const TransactionWeightDetailsModel();

    final commission = json['commission'] is Map
        ? TransactionCommissionModel.fromJson(
            Map<String, dynamic>.from(json['commission'] as Map),
          )
        : const TransactionCommissionModel();

    final handoverDetails = json['handoverDetails'] is Map
        ? TransactionHandoverDetailsModel.fromJson(
            Map<String, dynamic>.from(json['handoverDetails'] as Map),
          )
        : const TransactionHandoverDetailsModel();

    final paymentDetails = json['paymentDetails'] is Map
        ? TransactionPaymentDetailsModel.fromJson(
            Map<String, dynamic>.from(json['paymentDetails'] as Map),
          )
        : const TransactionPaymentDetailsModel();

    DateTime? completedAt;
    if (json['completedAt'] != null) {
      completedAt = DateTime.tryParse(json['completedAt'].toString());
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      updatedAt = DateTime.tryParse(json['updatedAt'].toString());
    }

    return TransactionModel(
      id: rawId.toString(),
      lotId: lotId,
      collectorId: collectorId,
      collectorName: collectorName,
      collectorPhone: collectorPhone,
      collectorAddress: collectorAddress,
      recyclerId: recyclerId,
      recyclerName: recyclerName,
      recyclerPhone: recyclerPhone,
      recyclerAddress: recyclerAddress,
      amount: _toDouble(json['amount']),
      paymentMethod: PaymentMethod.fromString(
        json['paymentMethod']?.toString(),
      ),
      paymentStatus: PaymentStatus.fromString(
        json['paymentStatus']?.toString(),
      ),
      paymentDetails: paymentDetails,
      handoverDetails: handoverDetails,
      weightDetails: weightDetails,
      commission: commission,
      status: TransactionStatus.fromString(json['status']?.toString()),
      notes: json['notes']?.toString(),
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lotStatus: lotStatus,
      lotEstimatedWeight: lotEstimatedWeight,
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      lotId: entity.lotId,
      collectorId: entity.collectorId,
      collectorName: entity.collectorName,
      collectorPhone: entity.collectorPhone,
      collectorAddress: entity.collectorAddress,
      recyclerId: entity.recyclerId,
      recyclerName: entity.recyclerName,
      recyclerPhone: entity.recyclerPhone,
      recyclerAddress: entity.recyclerAddress,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      paymentDetails: entity.paymentDetails,
      handoverDetails: entity.handoverDetails,
      weightDetails: entity.weightDetails,
      commission: entity.commission,
      status: entity.status,
      notes: entity.notes,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lotStatus: entity.lotStatus,
      lotEstimatedWeight: entity.lotEstimatedWeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'lotId': lotId,
      'collectorId': collectorId,
      'recyclerId': recyclerId,
      'amount': amount,
      'paymentMethod': paymentMethod.value,
      'paymentStatus': paymentStatus.value,
      'status': status.value,
      'paymentDetails': (paymentDetails is TransactionPaymentDetailsModel)
          ? (paymentDetails as TransactionPaymentDetailsModel).toJson()
          : TransactionPaymentDetailsModel.fromEntity(paymentDetails).toJson(),
      'handoverDetails': (handoverDetails is TransactionHandoverDetailsModel)
          ? (handoverDetails as TransactionHandoverDetailsModel).toJson()
          : TransactionHandoverDetailsModel.fromEntity(handoverDetails)
                .toJson(),
      'weightDetails': (weightDetails is TransactionWeightDetailsModel)
          ? (weightDetails as TransactionWeightDetailsModel).toJson()
          : TransactionWeightDetailsModel.fromEntity(weightDetails).toJson(),
      'commission': (commission is TransactionCommissionModel)
          ? (commission as TransactionCommissionModel).toJson()
          : TransactionCommissionModel.fromEntity(commission).toJson(),
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
