import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/matched_recycler_entity.dart';

abstract class MatchmakingEvent extends Equatable {
  const MatchmakingEvent();

  @override
  List<Object?> get props => [];
}

class FetchMatchedRecyclersEvent extends MatchmakingEvent {
  final String lotId;

  const FetchMatchedRecyclersEvent(this.lotId);

  @override
  List<Object?> get props => [lotId];
}

class AutoMatchRequestedEvent extends MatchmakingEvent {
  final String lotId;

  const AutoMatchRequestedEvent(this.lotId);

  @override
  List<Object?> get props => [lotId];
}

class SelectRecyclerEvent extends MatchmakingEvent {
  final MatchedRecyclerEntity recycler;

  const SelectRecyclerEvent(this.recycler);

  @override
  List<Object?> get props => [recycler];
}
