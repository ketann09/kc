import 'package:equatable/equatable.dart';

abstract class RecyclerLotDetailsEvent extends Equatable {
  const RecyclerLotDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecyclerLotDetailsEvent extends RecyclerLotDetailsEvent {
  final String lotId;

  const FetchRecyclerLotDetailsEvent(this.lotId);

  @override
  List<Object?> get props => [lotId];
}

class RetryRecyclerLotDetailsEvent extends RecyclerLotDetailsEvent {
  final String lotId;

  const RetryRecyclerLotDetailsEvent(this.lotId);

  @override
  List<Object?> get props => [lotId];
}

class AcceptRecyclerLotEvent extends RecyclerLotDetailsEvent {
  final String lotId;
  final double? price;

  const AcceptRecyclerLotEvent({required this.lotId, this.price});

  @override
  List<Object?> get props => [lotId, price];
}

class UpdateRecyclerLotLifecycleEvent extends RecyclerLotDetailsEvent {
  final String lotId;
  final String status;
  final double? actualWeight;
  final double? finalPrice;

  const UpdateRecyclerLotLifecycleEvent({
    required this.lotId,
    required this.status,
    this.actualWeight,
    this.finalPrice,
  });

  @override
  List<Object?> get props => [lotId, status, actualWeight, finalPrice];
}
