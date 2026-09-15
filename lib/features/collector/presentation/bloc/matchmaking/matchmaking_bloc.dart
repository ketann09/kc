import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../domain/usecases/collector/get_matched_recyclers_usecase.dart';
import 'matchmaking_event.dart';
import 'matchmaking_state.dart';

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final GetMatchedRecyclersUseCase getMatchedRecyclersUseCase;

  MatchmakingBloc({required this.getMatchedRecyclersUseCase})
    : super(const MatchmakingInitial()) {
    on<FetchMatchedRecyclersEvent>(_onFetchMatchedRecyclers);
    on<AutoMatchRequestedEvent>(_onAutoMatchRequested);
    on<SelectRecyclerEvent>(_onSelectRecycler);
  }

  Future<void> _onFetchMatchedRecyclers(
    FetchMatchedRecyclersEvent event,
    Emitter<MatchmakingState> emit,
  ) async {
    emit(const MatchmakingLoading());

    try {
      final result = await getMatchedRecyclersUseCase(event.lotId);

      if (result.matches.isEmpty && result.bestMatch == null) {
        emit(MatchmakingEmpty(lotId: event.lotId));
      } else {
        emit(
          MatchmakingLoaded(
            lotId: event.lotId,
            matches: result.matches,
            bestMatch: result.bestMatch,
            selectedRecycler:
                result.bestMatch ??
                (result.matches.isNotEmpty ? result.matches.first : null),
          ),
        );
      }
    } on ApiException catch (e) {
      emit(MatchmakingFailure(lotId: event.lotId, message: e.message));
    } catch (e) {
      emit(
        MatchmakingFailure(
          lotId: event.lotId,
          message: 'Failed to fetch recyclers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAutoMatchRequested(
    AutoMatchRequestedEvent event,
    Emitter<MatchmakingState> emit,
  ) async {
    emit(const MatchmakingLoading());

    try {
      final result = await getMatchedRecyclersUseCase.autoMatch(event.lotId);

      if (result.matches.isEmpty && result.bestMatch == null) {
        emit(MatchmakingEmpty(lotId: event.lotId));
      } else {
        emit(
          MatchmakingLoaded(
            lotId: event.lotId,
            matches: result.matches,
            bestMatch: result.bestMatch,
            selectedRecycler:
                result.bestMatch ??
                (result.matches.isNotEmpty ? result.matches.first : null),
          ),
        );
      }
    } on ApiException catch (e) {
      emit(MatchmakingFailure(lotId: event.lotId, message: e.message));
    } catch (e) {
      emit(
        MatchmakingFailure(
          lotId: event.lotId,
          message: 'Auto-match failed: ${e.toString()}',
        ),
      );
    }
  }

  void _onSelectRecycler(
    SelectRecyclerEvent event,
    Emitter<MatchmakingState> emit,
  ) {
    if (state is MatchmakingLoaded) {
      final current = state as MatchmakingLoaded;
      emit(current.copyWith(selectedRecycler: event.recycler));
    }
  }
}
