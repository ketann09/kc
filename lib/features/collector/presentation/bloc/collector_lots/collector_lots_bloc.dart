import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
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

  CollectorLotsBloc({
    required this.getCollectorLotsUseCase,
    required this.getLotDetailsUseCase,
    required this.getLiveScrapRatesUseCase,
  }) : super(const CollectorLotsInitial()) {
    on<CollectorDashboardInitRequested>(_onDashboardInit);
    on<CollectorLotsFetchRequested>(_onLotsFetch);
    on<CollectorLotDetailsRequested>(_onLotDetails);
  }

  Future<void> _onDashboardInit(
    CollectorDashboardInitRequested event,
    Emitter<CollectorLotsState> emit,
  ) async {
    emit(const CollectorLotsLoading());

    try {
      List<MaterialEntity> rates = [];
      List<LotEntity> lots = [];

      try {
        rates = await getLiveScrapRatesUseCase();
      } catch (_) {
        // Allow dashboard to load even if rates fail
      }

      try {
        lots = await getCollectorLotsUseCase(page: 1, limit: 5);
      } catch (_) {
        // Allow dashboard to load even if lots fail
      }

      emit(CollectorDashboardLoaded(liveRates: rates, recentLots: lots));
    } on ApiException catch (e) {
      emit(CollectorLotsFailure(e.message));
    } catch (e) {
      emit(CollectorLotsFailure('Failed to load dashboard: ${e.toString()}'));
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
    } else {
      emit(const CollectorLotsLoading());
    }

    try {
      final newLots = await getCollectorLotsUseCase(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

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
        ),
      );
    } on ApiException catch (e) {
      emit(CollectorLotsFailure(e.message));
    } catch (e) {
      emit(CollectorLotsFailure('Failed to load lots: ${e.toString()}'));
    }
  }

  Future<void> _onLotDetails(
    CollectorLotDetailsRequested event,
    Emitter<CollectorLotsState> emit,
  ) async {
    emit(const CollectorLotsLoading());

    try {
      final lot = await getLotDetailsUseCase(event.lotId);
      emit(CollectorLotDetailLoaded(lot));
    } on ApiException catch (e) {
      emit(CollectorLotsFailure(e.message));
    } catch (e) {
      emit(CollectorLotsFailure('Failed to load lot details: ${e.toString()}'));
    }
  }
}
