import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_exception.dart';
import '../../../../../../domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import '../../../../../../domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import '../../../../../../domain/usecases/recycler/update_lot_lifecycle_usecase.dart';
import 'recycler_lot_details_event.dart';
import 'recycler_lot_details_state.dart';

class RecyclerLotDetailsBloc
    extends Bloc<RecyclerLotDetailsEvent, RecyclerLotDetailsState> {
  final GetRecyclerLotDetailsUseCase getRecyclerLotDetailsUseCase;
  final AcceptRecyclerLotUseCase acceptRecyclerLotUseCase;
  final UpdateLotLifecycleUseCase updateLotLifecycleUseCase;

  RecyclerLotDetailsBloc({
    required this.getRecyclerLotDetailsUseCase,
    required this.acceptRecyclerLotUseCase,
    required this.updateLotLifecycleUseCase,
  }) : super(const RecyclerLotDetailsInitial()) {
    on<FetchRecyclerLotDetailsEvent>(_onFetchLotDetails);
    on<RetryRecyclerLotDetailsEvent>(_onRetryLotDetails);
    on<AcceptRecyclerLotEvent>(_onAcceptLot);
    on<UpdateRecyclerLotLifecycleEvent>(_onUpdateLotLifecycle);
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

  Future<void> _onUpdateLotLifecycle(
    UpdateRecyclerLotLifecycleEvent event,
    Emitter<RecyclerLotDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecyclerLotDetailsLoaded) return;
    if (currentState.isUpdatingLifecycle) return;

    final targetStatus = event.status.toLowerCase().trim();

    // Completion validation: defensively reject if actualWeight is null or <= 0
    if (targetStatus == 'completed') {
      if (event.actualWeight == null || event.actualWeight! <= 0) {
        emit(
          currentState.copyWith(
            isUpdatingLifecycle: false,
            actionErrorMessage:
                'लॉट पूरा करने के लिए वैध वास्तविक वजन (किलो) आवश्यक है',
          ),
        );
        return;
      }
    }

    emit(
      currentState.copyWith(
        isUpdatingLifecycle: true,
        actionErrorMessage: null,
        actionSuccessMessage: null,
      ),
    );

    // Final price resolution: preserve supplied finalPrice or fallback to lot's existing semantics on completed
    final double? resolvedFinalPrice =
        event.finalPrice ??
        (targetStatus == 'completed'
            ? (currentState.lot.finalPrice ?? currentState.lot.estimatedPrice)
            : null);

    try {
      final updatedLot = await updateLotLifecycleUseCase(
        lotId: event.lotId,
        status: event.status,
        actualWeight: event.actualWeight,
        finalPrice: resolvedFinalPrice,
      );

      String successMessage;
      switch (targetStatus) {
        case 'picked':
          successMessage = 'लॉट को सफलतापूर्वक उठाया गया चिह्नित किया गया';
          break;
        case 'delivered':
          successMessage = 'लॉट को सफलतापूर्वक डिलीवर चिह्नित किया गया';
          break;
        case 'completed':
          successMessage = 'लॉट सफलतापूर्वक पूरा कर दिया गया';
          break;
        default:
          successMessage = 'लॉट स्थिति सफलतापूर्वक अपडेट की गई';
      }

      emit(
        currentState.copyWith(
          lot: updatedLot,
          isUpdatingLifecycle: false,
          actionSuccessMessage: successMessage,
        ),
      );
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          isUpdatingLifecycle: false,
          actionErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isUpdatingLifecycle: false,
          actionErrorMessage:
              'लॉट स्थिति अपडेट करने में त्रुटि: ${e.toString()}',
        ),
      );
    }
  }
}
