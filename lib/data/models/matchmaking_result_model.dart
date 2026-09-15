import '../../domain/entities/matchmaking_result_entity.dart';
import 'matched_recycler_model.dart';

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class MatchmakingResultModel extends MatchmakingResultEntity {
  const MatchmakingResultModel({
    required super.lotId,
    super.materialName,
    super.estimatedWeight,
    super.matches,
    super.bestMatch,
  });

  factory MatchmakingResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final matchesRaw = data['matches'];
    final matchesList = matchesRaw is List
        ? matchesRaw
              .whereType<Map>()
              .map(
                (e) =>
                    MatchedRecyclerModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <MatchedRecyclerModel>[];

    final bestMatchRaw = data['bestMatch'];
    final best = bestMatchRaw is Map
        ? MatchedRecyclerModel.fromJson(Map<String, dynamic>.from(bestMatchRaw))
        : (matchesList.isNotEmpty ? matchesList.first : null);

    return MatchmakingResultModel(
      lotId: data['lotId']?.toString() ?? '',
      materialName: data['materialName']?.toString(),
      estimatedWeight: _toDoubleNullable(data['estimatedWeight']),
      matches: matchesList,
      bestMatch: best,
    );
  }
}
