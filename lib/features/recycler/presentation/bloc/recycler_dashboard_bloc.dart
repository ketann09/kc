import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'recycler_dashboard_event.dart';
import 'recycler_dashboard_state.dart';

class RecyclerDashboardBloc
    extends Bloc<RecyclerDashboardEvent, RecyclerDashboardState> {
  final GetRecyclerLotsUseCase getRecyclerLotsUseCase;

  RecyclerDashboardBloc({required this.getRecyclerLotsUseCase})
    : super(const RecyclerDashboardInitial()) {
    on<DashboardStarted>(_onDashboardStarted);
    on<FetchIncomingLots>(_onFetchIncomingLots);
  }

  Future<void> _onDashboardStarted(
    DashboardStarted event,
    Emitter<RecyclerDashboardState> emit,
  ) async {
    await _fetchLots(emit, page: 1, limit: 10, refresh: true);
  }

  Future<void> _onFetchIncomingLots(
    FetchIncomingLots event,
    Emitter<RecyclerDashboardState> emit,
  ) async {
    await _fetchLots(
      emit,
      page: event.page,
      limit: event.limit,
      status: event.status,
      refresh: event.refresh,
    );
  }

  Future<void> _fetchLots(
    Emitter<RecyclerDashboardState> emit, {
    int page = 1,
    int limit = 10,
    String? status,
    bool refresh = false,
  }) async {
    emit(const RecyclerDashboardLoading());

    try {
      final lots = await getRecyclerLotsUseCase(
        page: page,
        limit: limit,
        status: status,
      );

      if (lots.isEmpty) {
        emit(const RecyclerDashboardEmpty());
      } else {
        emit(
          RecyclerDashboardLoaded(
            lots: lots,
            currentPage: page,
            hasReachedMax: lots.length < limit,
          ),
        );
      }
    } on ApiException catch (e) {
      emit(RecyclerDashboardFailure(e.message));
    } catch (e) {
      emit(RecyclerDashboardFailure('Failed to load lots: ${e.toString()}'));
    }
  }
}
