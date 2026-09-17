import 'package:equatable/equatable.dart';

abstract class RecyclerDashboardEvent extends Equatable {
  const RecyclerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStarted extends RecyclerDashboardEvent {
  const DashboardStarted();
}

class FetchIncomingLots extends RecyclerDashboardEvent {
  final int page;
  final int limit;
  final String? status;
  final bool refresh;

  const FetchIncomingLots({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, status, refresh];
}
