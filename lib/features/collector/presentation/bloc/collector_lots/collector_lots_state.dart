import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/lot_entity.dart';
import '../../../../../domain/entities/material_entity.dart';

abstract class CollectorLotsState extends Equatable {
  const CollectorLotsState();

  @override
  List<Object?> get props => [];
}

class CollectorLotsInitial extends CollectorLotsState {
  const CollectorLotsInitial();
}

class CollectorLotsLoading extends CollectorLotsState {
  const CollectorLotsLoading();
}

class CollectorDashboardLoaded extends CollectorLotsState {
  final List<MaterialEntity> liveRates;
  final List<LotEntity> recentLots;
  final bool isOffline;
  final bool isRefreshing;
  final DateTime? cachedAt;
  final String? refreshError;

  const CollectorDashboardLoaded({
    required this.liveRates,
    required this.recentLots,
    this.isOffline = false,
    this.isRefreshing = false,
    this.cachedAt,
    this.refreshError,
  });

  CollectorDashboardLoaded copyWith({
    List<MaterialEntity>? liveRates,
    List<LotEntity>? recentLots,
    bool? isOffline,
    bool? isRefreshing,
    DateTime? cachedAt,
    String? refreshError,
  }) {
    return CollectorDashboardLoaded(
      liveRates: liveRates ?? this.liveRates,
      recentLots: recentLots ?? this.recentLots,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
      refreshError: refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    liveRates,
    recentLots,
    isOffline,
    isRefreshing,
    cachedAt,
    refreshError,
  ];
}

class CollectorLotsLoaded extends CollectorLotsState {
  final List<LotEntity> lots;
  final int currentPage;
  final bool hasReachedMax;
  final String? statusFilter;
  final bool isOffline;
  final bool isRefreshing;
  final DateTime? cachedAt;
  final String? refreshError;

  const CollectorLotsLoaded({
    required this.lots,
    required this.currentPage,
    required this.hasReachedMax,
    this.statusFilter,
    this.isOffline = false,
    this.isRefreshing = false,
    this.cachedAt,
    this.refreshError,
  });

  CollectorLotsLoaded copyWith({
    List<LotEntity>? lots,
    int? currentPage,
    bool? hasReachedMax,
    String? statusFilter,
    bool? isOffline,
    bool? isRefreshing,
    DateTime? cachedAt,
    String? refreshError,
  }) {
    return CollectorLotsLoaded(
      lots: lots ?? this.lots,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      statusFilter: statusFilter ?? this.statusFilter,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
      refreshError: refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    lots,
    currentPage,
    hasReachedMax,
    statusFilter,
    isOffline,
    isRefreshing,
    cachedAt,
    refreshError,
  ];
}

class CollectorLotDetailLoaded extends CollectorLotsState {
  final LotEntity lot;
  final bool isOffline;
  final DateTime? cachedAt;

  const CollectorLotDetailLoaded(
    this.lot, {
    this.isOffline = false,
    this.cachedAt,
  });

  @override
  List<Object?> get props => [lot, isOffline, cachedAt];
}

class CollectorLotsFailure extends CollectorLotsState {
  final String message;
  final bool isOffline;

  const CollectorLotsFailure(this.message, {this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}
