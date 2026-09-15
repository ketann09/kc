import 'package:equatable/equatable.dart';

class MatchedRecyclerScoreBreakdown extends Equatable {
  final num price;
  final num distance;
  final num rating;
  final num availability;

  const MatchedRecyclerScoreBreakdown({
    this.price = 0,
    this.distance = 0,
    this.rating = 0,
    this.availability = 0,
  });

  @override
  List<Object?> get props => [price, distance, rating, availability];
}

class MatchedRecyclerEntity extends Equatable {
  final String recyclerId;
  final String? recyclerName;
  final String? phoneNumber;
  final String? address;
  final double price;
  final double estimatedTotal;
  final double distance;
  final double score;
  final MatchedRecyclerScoreBreakdown? breakdown;
  final String? priceId;
  final DateTime? matchedAt;

  const MatchedRecyclerEntity({
    required this.recyclerId,
    this.recyclerName,
    this.phoneNumber,
    this.address,
    required this.price,
    this.estimatedTotal = 0,
    this.distance = 0,
    this.score = 0,
    this.breakdown,
    this.priceId,
    this.matchedAt,
  });

  @override
  List<Object?> get props => [
    recyclerId,
    recyclerName,
    phoneNumber,
    address,
    price,
    estimatedTotal,
    distance,
    score,
    breakdown,
    priceId,
    matchedAt,
  ];
}
