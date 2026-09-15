import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/matched_recycler_entity.dart';

abstract class MatchmakingState extends Equatable {
  const MatchmakingState();

  @override
  List<Object?> get props => [];
}

class MatchmakingInitial extends MatchmakingState {
  const MatchmakingInitial();
}

class MatchmakingLoading extends MatchmakingState {
  const MatchmakingLoading();
}

class MatchmakingLoaded extends MatchmakingState {
  final String lotId;
  final List<MatchedRecyclerEntity> matches;
  final MatchedRecyclerEntity? bestMatch;
  final MatchedRecyclerEntity? selectedRecycler;

  const MatchmakingLoaded({
    required this.lotId,
    required this.matches,
    this.bestMatch,
    this.selectedRecycler,
  });

  MatchmakingLoaded copyWith({
    String? lotId,
    List<MatchedRecyclerEntity>? matches,
    MatchedRecyclerEntity? bestMatch,
    MatchedRecyclerEntity? selectedRecycler,
  }) {
    return MatchmakingLoaded(
      lotId: lotId ?? this.lotId,
      matches: matches ?? this.matches,
      bestMatch: bestMatch ?? this.bestMatch,
      selectedRecycler: selectedRecycler ?? this.selectedRecycler,
    );
  }

  @override
  List<Object?> get props => [lotId, matches, bestMatch, selectedRecycler];
}

class MatchmakingEmpty extends MatchmakingState {
  final String lotId;
  final String message;

  const MatchmakingEmpty({
    required this.lotId,
    this.message = 'No matching recyclers found nearby.',
  });

  @override
  List<Object?> get props => [lotId, message];
}

class MatchmakingFailure extends MatchmakingState {
  final String lotId;
  final String message;

  const MatchmakingFailure({required this.lotId, required this.message});

  @override
  List<Object?> get props => [lotId, message];
}
