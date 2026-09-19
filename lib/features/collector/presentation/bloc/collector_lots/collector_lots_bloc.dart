import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/storage/read_cache_storage.dart';
import '../../../../../data/models/lot_model.dart';
import '../../../../../data/models/material_model.dart';
import '../../../../../domain/entities/lot_entity.dart';
import '../../../../../domain/entities/material_entity.dart';
import '../../../../../domain/usecases/collector/get_collector_lots_usecase.dart';
import '../../../../../domain/usecases/collector/get_live_scrap_rates_usecase.dart';
import '../../../../../domain/usecases/collector/get_lot_details_usecase.dart';
import 'collector_lots_event.dart';
import 'collector_lots_state.dart';

class CollectorLotsBloc extends Bloc<CollectorLotsEvent, CollectorLotsState> {
  final GetCollectorLotsUseCase getCollectorLotsUseCase;
  final GetLotDetailsUseCase getLotDetailsUseCase;
  final GetLiveScrapRatesUseCase getLiveScrapRatesUseCase;
  final ReadCacheStorage? readCacheStorage;

  CollectorLotsBloc({
    required this.getCollectorLotsUseCase,
    required this.getLotDetailsUseCase,
    required this.getLiveScrapRatesUseCase,
    this.readCacheStorage,
  }) : super(const CollectorLotsInitial()) {
    on<CollectorDashboardInitRequested>(_onDashboardInit);
    on<CollectorLotsFetchRequested>(_onLotsFetch);
    on<CollectorLotDetailsRequested>(_onLotDetails);
  }

  Future<void> _onDashboardInit(
    CollectorDashboardInitRequested event,
    Emitter<CollectorLotsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CollectorDashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true, refreshError: null));
    } else {
      emit(const CollectorLotsLoading());
    }

    try {
      final rates = await getLiveScrapRatesUseCase();
      final lots = await getCollectorLotsUseCase(page: 1, limit: 5);

      if (readCacheStorage != null) {
        if (rates.isNotEmpty) {
          await readCacheStorage!.saveList<MaterialEntity>(
            key: 'collector_live_rates',
            data: rates,
            toJson: (item) => MaterialModel.fromEntity(item).toJson(),
          );
        }
        await readCacheStorage!.saveList<LotEntity>(
          key: 'collector_recent_lots',
          data: lots,
          toJson: (item) => LotModel.fromEntity(item).toJson(),
        );
      }

      emit(CollectorDashboardLoaded(
        liveRates: rates,
        recentLots: lots,
        isOffline: false,
        isRefreshing: false,
      ));
    } on ApiException catch (e) {
      final isOffline = e.isNetworkError || e.isTimeout;
      if (currentState is CollectorDashboardLoaded) {
        emit(currentState.copyWith(
          isRefreshing: false,
          isOffline: isOffline,
          refreshError: e.message,
        ));
      } else {
        final cachedLots = await readCacheStorage?.getList<LotEntity>(
          key: 'collector_recent_lots',
          fromJson: (json) => LotModel.fromJson(json),
        );
        final cachedRates = await readCacheStorage?.getList<MaterialEntity>(
          key: 'collector_live_rates',
          fromJson: (json) => MaterialModel.fromJson(json),
        );

        if (cachedLots != null || cachedRates != null) {
          emit(CollectorDashboardLoaded(
            liveRates: cachedRates?.data ?? [],
            recentLots: cachedLots?.data ?? [],
            isOffline: true,
            cachedAt: cachedLots?.cachedAt ?? cachedRates?.cachedAt,
            refreshError: e.message,
          ));
        } else {
          emit(CollectorLotsFailure(e.message, isOffline: isOffline));
        }
      }
    } catch (e) {
      if (currentState is CollectorDashboardLoaded) {
        emit(currentState.copyWith(
          isRefreshing: false,
          isOffline: true,
          refreshError: e.toString(),
        ));
      } else {
        emit(CollectorLotsFailure('Failed to load dashboard: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLotsFetch(
    CollectorLotsFetchRequested event,
    Emitter<CollectorLotsState> emit,
  ) async {
    final currentState = state;
    List<LotEntity> currentLots = [];

    if (!event.refresh && currentState is CollectorLotsLoaded) {
      if (currentState.hasReachedMax) return;
      currentLots = currentState.lots;
    } else if (event.refresh && currentState is CollectorLotsLoaded) {
      emit(currentState.copyWith(isRefreshing: true, refreshError: null));
    } else {
      emit(const CollectorLotsLoading());
    }

    try {
      final newLots = await getCollectorLotsUseCase(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      if (event.page == 1 && readCacheStorage != null) {
        await readCacheStorage!.saveList<LotEntity>(
          key: 'collector_lots',
          data: newLots,
          toJson: (item) => LotModel.fromEntity(item).toJson(),
        );
      }

      final hasReachedMax = newLots.length < event.limit;
      final combined = event.refresh || event.page == 1
          ? newLots
          : [...currentLots, ...newLots];

      emit(
        CollectorLotsLoaded(
          lots: combined,
          currentPage: event.page,
          hasReachedMax: hasReachedMax,
          statusFilter: event.status,
          isOffline: false,
          isRefreshing: false,
        ),
      );
    } on ApiException catch (e) {
      final isOffline = e.isNetworkError || e.isTimeout;
      if (currentState is CollectorLotsLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: isOffline,
            refreshError: e.message,
          ),
        );
      } else {
        final cached = await readCacheStorage?.getList<LotEntity>(
          key: 'collector_lots',
          fromJson: (json) => LotModel.fromJson(json),
        );
        if (cached != null) {
          emit(
            CollectorLotsLoaded(
              lots: cached.data,
              currentPage: 1,
              hasReachedMax: true,
              isOffline: true,
              cachedAt: cached.cachedAt,
              refreshError: e.message,
            ),
          );
        } else {
          emit(CollectorLotsFailure(e.message, isOffline: isOffline));
        }
      }
    } catch (e) {
      if (currentState is CollectorLotsLoaded) {
        emit(
          currentState.copyWith(
            isRefreshing: false,
            isOffline: true,
            refreshError: e.toString(),
          ),
        );
      } else {
        emit(CollectorLotsFailure('Failed to load lots: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLotDetails(
    CollectorLotDetailsRequested event,
    Emitter<CollectorLotsState> emit,
  ) async {
    emit(const CollectorLotsLoading());

    try {
      final lot = await getLotDetailsUseCase(event.lotId);
      if (readCacheStorage != null) {
        await readCacheStorage!.save<LotEntity>(
          key: 'lot_detail_${event.lotId}',
          data: lot,
          toJson: (item) => LotModel.fromEntity(item).toJson(),
        );
      }
      emit(CollectorLotDetailLoaded(lot, isOffline: false));
    } on ApiException catch (e) {
      final cached = await readCacheStorage?.get<LotEntity>(
        key: 'lot_detail_${event.lotId}',
        fromJson: (json) => LotModel.fromJson(json),
      );
      if (cached != null) {
        emit(CollectorLotDetailLoaded(
          cached.data,
          isOffline: true,
          cachedAt: cached.cachedAt,
        ));
      } else {
        emit(CollectorLotsFailure(e.message, isOffline: true));
      }
    } catch (e) {
      final cached = await readCacheStorage?.get<LotEntity>(
        key: 'lot_detail_${event.lotId}',
        fromJson: (json) => LotModel.fromJson(json),
      );
      if (cached != null) {
        emit(CollectorLotDetailLoaded(
          cached.data,
          isOffline: true,
          cachedAt: cached.cachedAt,
        ));
      } else {
        emit(CollectorLotsFailure('Failed to load lot details: ${e.toString()}'));
      }
    }
  }
}
