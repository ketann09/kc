import 'package:equatable/equatable.dart';

abstract class CollectorLotsEvent extends Equatable {
  const CollectorLotsEvent();

  @override
  List<Object?> get props => [];
}

class CollectorDashboardInitRequested extends CollectorLotsEvent {
  const CollectorDashboardInitRequested();
}

class CollectorLotsFetchRequested extends CollectorLotsEvent {
  final int page;
  final int limit;
  final String? status;
  final bool refresh;

  const CollectorLotsFetchRequested({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, status, refresh];
}

class CollectorLotDetailsRequested extends CollectorLotsEvent {
  final String lotId;

  const CollectorLotDetailsRequested(this.lotId);

  @override
  List<Object?> get props => [lotId];
}
