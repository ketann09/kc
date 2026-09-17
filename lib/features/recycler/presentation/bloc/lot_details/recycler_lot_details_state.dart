import 'package:equatable/equatable.dart';

import '../../../../../../domain/entities/lot_entity.dart';

abstract class RecyclerLotDetailsState extends Equatable {
  const RecyclerLotDetailsState();

  @override
  List<Object?> get props => [];
}

class RecyclerLotDetailsInitial extends RecyclerLotDetailsState {
  const RecyclerLotDetailsInitial();
}

class RecyclerLotDetailsLoading extends RecyclerLotDetailsState {
  const RecyclerLotDetailsLoading();
}

class RecyclerLotDetailsLoaded extends RecyclerLotDetailsState {
  final LotEntity lot;
  final bool isAccepting;
  final bool isUpdatingLifecycle;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  const RecyclerLotDetailsLoaded(
    this.lot, {
    this.isAccepting = false,
    this.isUpdatingLifecycle = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
  });

  RecyclerLotDetailsLoaded copyWith({
    LotEntity? lot,
    bool? isAccepting,
    bool? isUpdatingLifecycle,
    String? actionSuccessMessage,
    String? actionErrorMessage,
  }) {
    return RecyclerLotDetailsLoaded(
      lot ?? this.lot,
      isAccepting: isAccepting ?? this.isAccepting,
      isUpdatingLifecycle: isUpdatingLifecycle ?? this.isUpdatingLifecycle,
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    lot,
    isAccepting,
    isUpdatingLifecycle,
    actionSuccessMessage,
    actionErrorMessage,
  ];
}

class RecyclerLotDetailsFailure extends RecyclerLotDetailsState {
  final String message;

  const RecyclerLotDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
