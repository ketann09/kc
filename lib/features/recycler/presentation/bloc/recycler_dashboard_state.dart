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

  const RecyclerDashboardLoaded({
    required this.lots,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [lots, currentPage, hasReachedMax];
}

class RecyclerDashboardEmpty extends RecyclerDashboardState {
  const RecyclerDashboardEmpty();
}

class RecyclerDashboardFailure extends RecyclerDashboardState {
  final String message;

  const RecyclerDashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}
