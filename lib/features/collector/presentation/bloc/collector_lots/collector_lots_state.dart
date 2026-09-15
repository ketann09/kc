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

  const CollectorDashboardLoaded({
    required this.liveRates,
    required this.recentLots,
  });

  @override
  List<Object?> get props => [liveRates, recentLots];
}

class CollectorLotsLoaded extends CollectorLotsState {
  final List<LotEntity> lots;
  final int currentPage;
  final bool hasReachedMax;
  final String? statusFilter;

  const CollectorLotsLoaded({
    required this.lots,
    required this.currentPage,
    required this.hasReachedMax,
    this.statusFilter,
  });

  CollectorLotsLoaded copyWith({
    List<LotEntity>? lots,
    int? currentPage,
    bool? hasReachedMax,
    String? statusFilter,
  }) {
    return CollectorLotsLoaded(
      lots: lots ?? this.lots,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [lots, currentPage, hasReachedMax, statusFilter];
}

class CollectorLotDetailLoaded extends CollectorLotsState {
  final LotEntity lot;

  const CollectorLotDetailLoaded(this.lot);

  @override
  List<Object?> get props => [lot];
}

class CollectorLotsFailure extends CollectorLotsState {
  final String message;

  const CollectorLotsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
