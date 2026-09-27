import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/lot_entity.dart';

abstract class NewLotEvent extends Equatable {
  const NewLotEvent();

  @override
  List<Object?> get props => [];
}

class NewLotImageSelected extends NewLotEvent {
  final String imagePath;
  final String? state;
  final String? city;

  const NewLotImageSelected(this.imagePath, {this.state, this.city});

  @override
  List<Object?> get props => [imagePath, state, city];
}

class NewLotCategoryChanged extends NewLotEvent {
  final String? category;
  final bool isManual;
  final String? state;
  final String? city;

  const NewLotCategoryChanged({
    required this.category,
    this.isManual = true,
    this.state,
    this.city,
  });

  @override
  List<Object?> get props => [category, isManual, state, city];
}

class NewLotWeightQuantityChanged extends NewLotEvent {
  final double weightKg;
  final int quantity;
  final String? state;
  final String? city;

  const NewLotWeightQuantityChanged({
    required this.weightKg,
    this.quantity = 1,
    this.state,
    this.city,
  });

  @override
  List<Object?> get props => [weightKg, quantity, state, city];
}

class NewLotEstimatePriceRequested extends NewLotEvent {
  final String state;
  final String city;

  const NewLotEstimatePriceRequested({required this.state, required this.city});

  @override
  List<Object?> get props => [state, city];
}

class NewLotSubmitted extends NewLotEvent {
  final LotLocationEntity location;
  final String? description;
  final String? subCategory;
  final String? materialId;
  final String? state;
  final String? city;

  const NewLotSubmitted({
    required this.location,
    this.description,
    this.subCategory,
    this.materialId,
    this.state,
    this.city,
  });

  @override
  List<Object?> get props => [
    location,
    description,
    subCategory,
    materialId,
    state,
    city,
  ];
}

class NewLotReset extends NewLotEvent {
  const NewLotReset();
}
