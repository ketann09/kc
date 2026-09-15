import 'package:equatable/equatable.dart';

import 'matched_recycler_entity.dart';

class MatchmakingResultEntity extends Equatable {
  final String lotId;
  final String? materialName;
  final double? estimatedWeight;
  final List<MatchedRecyclerEntity> matches;
  final MatchedRecyclerEntity? bestMatch;

  const MatchmakingResultEntity({
    required this.lotId,
    this.materialName,
    this.estimatedWeight,
    this.matches = const [],
    this.bestMatch,
  });

  @override
  List<Object?> get props => [
    lotId,
    materialName,
    estimatedWeight,
    matches,
    bestMatch,
  ];
}
