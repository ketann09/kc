import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_exception.dart';
import '../../../../../../domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import '../../../../../../domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import 'recycler_lot_details_event.dart';
import 'recycler_lot_details_state.dart';

class RecyclerLotDetailsBloc
    extends Bloc<RecyclerLotDetailsEvent, RecyclerLotDetailsState> {
  final GetRecyclerLotDetailsUseCase getRecyclerLotDetailsUseCase;
  final AcceptRecyclerLotUseCase acceptRecyclerLotUseCase;

  RecyclerLotDetailsBloc({
    required this.getRecyclerLotDetailsUseCase,
    required this.acceptRecyclerLotUseCase,
  }) : super(const RecyclerLotDetailsInitial()) {
    on<FetchRecyclerLotDetailsEvent>(_onFetchLotDetails);
    on<RetryRecyclerLotDetailsEvent>(_onRetryLotDetails);
    on<AcceptRecyclerLotEvent>(_onAcceptLot);
  }

  Future<void> _onFetchLotDetails(
    FetchRecyclerLotDetailsEvent event,
    Emitter<RecyclerLotDetailsState> emit,
  ) async {
    await _loadLot(event.lotId, emit);
  }

  Future<void> _onRetryLotDetails(
    RetryRecyclerLotDetailsEvent event,
    Emitter<RecyclerLotDetailsState> emit,
  ) async {
    await _loadLot(event.lotId, emit);
  }

  Future<void> _loadLot(
    String lotId,
    Emitter<RecyclerLotDetailsState> emit,
  ) async {
    emit(const RecyclerLotDetailsLoading());

    try {
      final lot = await getRecyclerLotDetailsUseCase(lotId);
      emit(RecyclerLotDetailsLoaded(lot));
    } on ApiException catch (e) {
      emit(RecyclerLotDetailsFailure(e.message));
    } catch (e) {
      emit(
        RecyclerLotDetailsFailure('लॉट विवरण लोड नहीं हो सका: ${e.toString()}'),
      );
    }
  }

  Future<void> _onAcceptLot(
    AcceptRecyclerLotEvent event,
    Emitter<RecyclerLotDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecyclerLotDetailsLoaded) {
      emit(
        currentState.copyWith(
          isAccepting: true,
          actionErrorMessage: null,
          actionSuccessMessage: null,
        ),
      );

      try {
        final updatedLot = await acceptRecyclerLotUseCase(
          lotId: event.lotId,
          price: event.price,
        );
        emit(
          currentState.copyWith(
            lot: updatedLot,
            isAccepting: false,
            actionSuccessMessage: 'लॉट सफलतापूर्वक स्वीकार कर लिया गया है',
          ),
        );
      } on ApiException catch (e) {
        emit(
          currentState.copyWith(
            isAccepting: false,
            actionErrorMessage: e.message,
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            isAccepting: false,
            actionErrorMessage: 'लॉट स्वीकार करने में त्रुटि: ${e.toString()}',
          ),
        );
      }
    }
  }
}
