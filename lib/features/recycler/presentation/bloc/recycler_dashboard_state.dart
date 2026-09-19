import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/lot_entity.dart';

abstract class RecyclerDashboardState extends Equatable {
  const RecyclerDashboardState();

  @override
  List<Object?> get props => [];
}

class RecyclerDashboardInitial extends RecyclerDashboardState {
  const RecyclerDashboardInitial();
}

class RecyclerDashboardLoading extends RecyclerDashboardState {
  const RecyclerDashboardLoading();
}

class RecyclerDashboardLoaded extends RecyclerDashboardState {
  final List<LotEntity> lots;
  final int currentPage;
  final bool hasReachedMax;
  final bool isOffline;
  final bool isRefreshing;
  final DateTime? cachedAt;
  final String? refreshError;

  const RecyclerDashboardLoaded({
    required this.lots,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isOffline = false,
    this.isRefreshing = false,
    this.cachedAt,
    this.refreshError,
  });

  RecyclerDashboardLoaded copyWith({
    List<LotEntity>? lots,
    int? currentPage,
    bool? hasReachedMax,
    bool? isOffline,
    bool? isRefreshing,
    DateTime? cachedAt,
    String? refreshError,
  }) {
    return RecyclerDashboardLoaded(
      lots: lots ?? this.lots,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
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
    isOffline,
    isRefreshing,
    cachedAt,
    refreshError,
  ];
}

class RecyclerDashboardEmpty extends RecyclerDashboardState {
  const RecyclerDashboardEmpty();
}

class RecyclerDashboardFailure extends RecyclerDashboardState {
  final String message;
  final bool isOffline;

  const RecyclerDashboardFailure(this.message, {this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}
