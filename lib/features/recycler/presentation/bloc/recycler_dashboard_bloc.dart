import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/storage/read_cache_storage.dart';
import '../../../../../data/models/lot_model.dart';
import '../../../../../domain/entities/lot_entity.dart';
import '../../../../../domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'recycler_dashboard_event.dart';
import 'recycler_dashboard_state.dart';

class RecyclerDashboardBloc
    extends Bloc<RecyclerDashboardEvent, RecyclerDashboardState> {
  final GetRecyclerLotsUseCase getRecyclerLotsUseCase;
  final ReadCacheStorage? readCacheStorage;

  RecyclerDashboardBloc({
    required this.getRecyclerLotsUseCase,
    this.readCacheStorage,
  }) : super(const RecyclerDashboardInitial()) {
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
    final currentState = state;
    if (refresh && currentState is RecyclerDashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true, refreshError: null));
    } else {
      emit(const RecyclerDashboardLoading());
    }

    try {
      final lots = await getRecyclerLotsUseCase(
        page: page,
        limit: limit,
        status: status,
      );

      if (page == 1 && readCacheStorage != null) {
        await readCacheStorage!.saveList<LotEntity>(
          key: 'recycler_incoming_lots',
          data: lots,
          toJson: (item) => LotModel.fromEntity(item).toJson(),
        );
      }

      if (lots.isEmpty) {
        emit(const RecyclerDashboardEmpty());
      } else {
        emit(
          RecyclerDashboardLoaded(
            lots: lots,
            currentPage: page,
            hasReachedMax: lots.length < limit,
            isOffline: false,
            isRefreshing: false,
          ),
        );
      }
    } on ApiException catch (e) {
      final isOffline = e.isNetworkError || e.isTimeout;
      if (currentState is RecyclerDashboardLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: isOffline,
            refreshError: e.message,
          ),
        );
      } else {
        final cached = await readCacheStorage?.getList<LotEntity>(
          key: 'recycler_incoming_lots',
          fromJson: (json) => LotModel.fromJson(json),
        );
        if (cached != null && cached.data.isNotEmpty) {
          emit(
            RecyclerDashboardLoaded(
              lots: cached.data,
              currentPage: 1,
              hasReachedMax: true,
              isOffline: true,
              cachedAt: cached.cachedAt,
              refreshError: e.message,
            ),
          );
        } else {
          emit(RecyclerDashboardFailure(e.message, isOffline: isOffline));
        }
      }
    } catch (e) {
      if (currentState is RecyclerDashboardLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: true,
            refreshError: e.toString(),
          ),
        );
      } else {
        emit(RecyclerDashboardFailure('Failed to load lots: ${e.toString()}'));
      }
    }
  }
}
