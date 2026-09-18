import 'package:equatable/equatable.dart';

abstract class CollectorTransactionsEvent extends Equatable {
  const CollectorTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCollectorTransactionsEvent extends CollectorTransactionsEvent {
  final bool refresh;
  final String? status;

  const FetchCollectorTransactionsEvent({this.refresh = false, this.status});

  @override
  List<Object?> get props => [refresh, status];
}

class FilterCollectorTransactionsEvent extends CollectorTransactionsEvent {
  final String? status;

  const FilterCollectorTransactionsEvent(this.status);

  @override
  List<Object?> get props => [status];
}
