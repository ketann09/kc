import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../data/models/ml_price_model.dart';
import '../../../../../domain/entities/lot_entity.dart';
import '../../../../../domain/entities/ml_price_entity.dart';
import '../../../../../domain/usecases/collector/classify_scrap_image_usecase.dart';
import '../../../../../domain/usecases/collector/create_collector_lot_usecase.dart';
import '../../../../../domain/usecases/collector/estimate_price_usecase.dart';
import 'new_lot_event.dart';
import 'new_lot_state.dart';

class NewLotBloc extends Bloc<NewLotEvent, NewLotState> {
  final ClassifyScrapImageUseCase classifyScrapImageUseCase;
  final EstimatePriceUseCase estimatePriceUseCase;
  final CreateCollectorLotUseCase createCollectorLotUseCase;
  final Duration pricingDebounceDuration;
  int _pricingRequestId = 0;

  NewLotBloc({
    required this.classifyScrapImageUseCase,
    required this.estimatePriceUseCase,
    required this.createCollectorLotUseCase,
    this.pricingDebounceDuration = const Duration(milliseconds: 300),
  }) : super(const NewLotState()) {
    on<NewLotImageSelected>(_onImageSelected);
    on<NewLotCategoryChanged>(_onCategoryChanged);
    on<NewLotWeightQuantityChanged>(_onWeightQuantityChanged);
    on<NewLotEstimatePriceRequested>(_onEstimatePriceRequested);
    on<NewLotSubmitted>(_onSubmitted);
    on<NewLotReset>(_onReset);
  }

  Future<void> _onImageSelected(
    NewLotImageSelected event,
    Emitter<NewLotState> emit,
  ) async {
    debugPrint(
      '[ML_DEBUG] NewLotBloc._onImageSelected received image path: ${event.imagePath}',
    );
    emit(
      state.copyWith(
        status: NewLotStatus.classifying,
        imagePath: event.imagePath,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    try {
      final classification = await classifyScrapImageUseCase(
        imagePath: event.imagePath,
      );

      debugPrint(
        '[ML_DEBUG] Classification success in NewLotBloc: category=${classification.category}, confidence=${classification.confidencePercent}%',
      );

      emit(
        state.copyWith(
          status: NewLotStatus.classified,
          classification: classification,
          category: classification.category,
          isManualCategory: false,
          errorType: NewLotErrorType.none,
          clearErrorMessage: true,
        ),
      );

      if (event.state != null &&
          event.state!.isNotEmpty &&
          event.city != null &&
          event.city!.isNotEmpty &&
          state.weightKg >= 0.1) {
        await _runPriceEstimation(
          emit: emit,
          category: classification.category,
          stateName: event.state!,
          cityName: event.city!,
          weightKg: state.weightKg,
          quantity: state.quantity,
        );
      }
    } on ApiException catch (e) {
      debugPrint('[ML_DEBUG] ApiException after conversion:');
      debugPrint('[ML_DEBUG]   ApiException type: ${e.type}');
      debugPrint('[ML_DEBUG]   ApiException message: ${e.message}');
      debugPrint('[ML_DEBUG]   ApiException status code: ${e.statusCode}');
      debugPrint('[ML_DEBUG]   ApiException data: ${e.data}');
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.classification,
          errorMessage: e.message,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[ML_DEBUG] Unexpected exception in NewLotBloc._onImageSelected: $e',
      );
      debugPrint('[ML_DEBUG] Stack trace: $stackTrace');
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.classification,
          errorMessage: 'Classification failed: ${e.toString()}',
        ),
      );
    }
  }

  static MLPriceEntity getStandardPriceEstimate({
    required String category,
    required double weightKg,
    required int quantity,
  }) {
    final cat = category.trim().toLowerCase();
    double rate = 50.0;
    String unit = 'per_kg';

    if (cat.contains('crt')) {
      rate = 150.0;
      unit = 'Piece';
    } else if (cat.contains('e-waste') ||
        cat.contains('pcb') ||
        cat.contains('ewaste') ||
        cat.contains('ई-वेस्ट')) {
      rate = 210.0;
      unit = 'per_kg';
    } else if (cat.contains('motor')) {
      rate = 180.0;
      unit = 'per_kg';
    } else if (cat.contains('cable') ||
        cat.contains('wire') ||
        cat.contains('copper') ||
        cat.contains('केबल')) {
      rate = 140.0;
      unit = 'per_kg';
    } else if (cat.contains('metal') ||
        cat.contains('iron') ||
        cat.contains('लोहा') ||
        cat.contains('धातु')) {
      rate = 140.0;
      unit = 'per_kg';
    } else if (cat.contains('lcd') || cat.contains('led')) {
      rate = 120.0;
      unit = 'per_kg';
    } else if (cat.contains('battery') ||
        cat.contains('बैटरी') ||
        cat.contains('बॅटरी')) {
      rate = 85.0;
      unit = 'per_kg';
    } else if (cat.contains('plastic') || cat.contains('प्लास्टिक')) {
      rate = 25.0;
      unit = 'per_kg';
    } else if (cat.contains('paper') ||
        cat.contains('cardboard') ||
        cat.contains('कागज') ||
        cat.contains('कागद')) {
      rate = 15.0;
      unit = 'per_kg';
    } else {
      rate = 50.0;
      unit = 'per_kg';
    }

    final isPiece = unit.toLowerCase().contains('piece') || cat.contains('crt');
    final multiplier = isPiece
        ? (quantity > 0 ? quantity.toDouble() : 1.0)
        : (weightKg > 0 ? weightKg : 1.0);
    final estValue = rate * multiplier;

    return MLPriceModel(
      category: category,
      recommendedRateInr: rate,
      unit: unit,
      estimatedValueInr: estValue,
      estimatedValueMinInr: estValue * 0.9,
      estimatedValueMaxInr: estValue * 1.1,
      matchLevel: 'standard_rates',
    );
  }

  Future<void> _onCategoryChanged(
    NewLotCategoryChanged event,
    Emitter<NewLotState> emit,
  ) async {
    if (event.category == null) {
      // User tapped the already selected category again -> Deselect!
      emit(
        state.copyWith(
          status: NewLotStatus.initial,
          clearCategory: true,
          clearClassification: true,
          clearPriceEstimate: true,
          isManualCategory: false,
          errorType: NewLotErrorType.none,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final isPiece = (event.category ?? '').toLowerCase().contains('crt');
    final qty = isPiece
        ? (state.quantity >= 1 ? state.quantity : 1)
        : state.quantity;
    final wt = isPiece ? qty.toDouble() : state.weightKg;

    final initialEstimate = getStandardPriceEstimate(
      category: event.category!,
      weightKg: wt,
      quantity: qty,
    );

    emit(
      state.copyWith(
        status: NewLotStatus.priced,
        category: event.category,
        isManualCategory: event.isManual,
        quantity: qty,
        weightKg: wt,
        priceEstimate: initialEstimate,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    if (event.state != null &&
        event.state!.isNotEmpty &&
        event.city != null &&
        event.city!.isNotEmpty) {
      await _runPriceEstimation(
        emit: emit,
        category: event.category!,
        stateName: event.state!,
        cityName: event.city!,
        weightKg: wt,
        quantity: qty,
        fallbackToStandard: true,
      );
    }
  }

  Future<void> _onWeightQuantityChanged(
    NewLotWeightQuantityChanged event,
    Emitter<NewLotState> emit,
  ) async {
    MLPriceEntity? recalculatedPrice = state.priceEstimate;
    final cat = state.category;
    if (recalculatedPrice != null && recalculatedPrice.recommendedRateInr > 0) {
      final isPiece =
          (cat ?? '').toLowerCase().contains('crt') ||
          recalculatedPrice.unit.toLowerCase().contains('piece');
      final multiplier = isPiece ? event.quantity.toDouble() : event.weightKg;
      final newValue = recalculatedPrice.recommendedRateInr * multiplier;
      final ratio = recalculatedPrice.estimatedValueInr > 0
          ? newValue / recalculatedPrice.estimatedValueInr
          : 1.0;
      recalculatedPrice = MLPriceModel(
        category: recalculatedPrice.category,
        recommendedRateInr: recalculatedPrice.recommendedRateInr,
        unit: recalculatedPrice.unit,
        estimatedValueInr: newValue,
        estimatedValueMinInr: recalculatedPrice.estimatedValueMinInr * ratio,
        estimatedValueMaxInr: recalculatedPrice.estimatedValueMaxInr * ratio,
        matchLevel: recalculatedPrice.matchLevel,
      );
    } else if (cat != null && cat.isNotEmpty) {
      recalculatedPrice = getStandardPriceEstimate(
        category: cat,
        weightKg: event.weightKg,
        quantity: event.quantity,
      );
    }

    emit(
      state.copyWith(
        weightKg: event.weightKg,
        quantity: event.quantity,
        priceEstimate: recalculatedPrice,
        status: recalculatedPrice != null ? NewLotStatus.priced : state.status,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    if (cat != null &&
        cat.isNotEmpty &&
        event.state != null &&
        event.state!.isNotEmpty &&
        event.city != null &&
        event.city!.isNotEmpty) {
      await _runPriceEstimation(
        emit: emit,
        category: cat,
        stateName: event.state!,
        cityName: event.city!,
        weightKg: event.weightKg,
        quantity: event.quantity,
        debounce: true,
        fallbackToStandard: true,
      );
    }
  }

  Future<void> _onEstimatePriceRequested(
    NewLotEstimatePriceRequested event,
    Emitter<NewLotState> emit,
  ) async {
    final cat = state.category;
    if (cat == null || cat.isEmpty) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.pricing,
          errorMessage: 'Please select a category first',
        ),
      );
      return;
    }

    await _runPriceEstimation(
      emit: emit,
      category: cat,
      stateName: event.state,
      cityName: event.city,
      weightKg: state.weightKg,
      quantity: state.quantity,
    );
  }

  Future<void> _runPriceEstimation({
    required Emitter<NewLotState> emit,
    required String category,
    required String stateName,
    required String cityName,
    required double weightKg,
    required int quantity,
    bool debounce = false,
    bool fallbackToStandard = false,
  }) async {
    final currentRequestId = ++_pricingRequestId;

    if (debounce && pricingDebounceDuration > Duration.zero) {
      await Future.delayed(pricingDebounceDuration);
      if (currentRequestId != _pricingRequestId) {
        return; // Superseded by a newer pricing request
      }
    }

    emit(
      state.copyWith(
        status: NewLotStatus.pricing,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    try {
      final price = await estimatePriceUseCase(
        category: category,
        state: stateName,
        city: cityName,
        quantity: quantity,
        totalWeightKg: weightKg,
      );

      if (currentRequestId != _pricingRequestId) {
        return; // Stale pricing response dropped
      }

      emit(
        state.copyWith(
          status: NewLotStatus.priced,
          priceEstimate: price,
          errorType: NewLotErrorType.none,
          clearErrorMessage: true,
        ),
      );
    } on ApiException catch (e) {
      if (currentRequestId != _pricingRequestId) return;
      if (fallbackToStandard || state.priceEstimate != null) {
        final fallback =
            state.priceEstimate ??
            getStandardPriceEstimate(
              category: category,
              weightKg: weightKg,
              quantity: quantity,
            );
        emit(
          state.copyWith(
            status: NewLotStatus.priced,
            priceEstimate: fallback,
            errorType: NewLotErrorType.none,
            clearErrorMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: NewLotStatus.failure,
            errorType: NewLotErrorType.pricing,
            errorMessage: e.message,
          ),
        );
      }
    } catch (e) {
      if (currentRequestId != _pricingRequestId) return;
      if (fallbackToStandard || state.priceEstimate != null) {
        final fallback =
            state.priceEstimate ??
            getStandardPriceEstimate(
              category: category,
              weightKg: weightKg,
              quantity: quantity,
            );
        emit(
          state.copyWith(
            status: NewLotStatus.priced,
            priceEstimate: fallback,
            errorType: NewLotErrorType.none,
            clearErrorMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: NewLotStatus.failure,
            errorType: NewLotErrorType.pricing,
            errorMessage: 'Price estimation failed: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onSubmitted(
    NewLotSubmitted event,
    Emitter<NewLotState> emit,
  ) async {
    if (state.status == NewLotStatus.submitting) {
      return;
    }

    if (state.category == null || state.category!.isEmpty) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.submission,
          errorMessage: 'Please select a category for the lot',
        ),
      );
      return;
    }

    final cat = (state.category ?? '').toLowerCase();
    final unit = (state.priceEstimate?.unit ?? '').toLowerCase();
    final isPiece = cat.contains('crt') || unit.contains('piece');

    if (isPiece) {
      if (state.quantity < 1) {
        emit(
          state.copyWith(
            status: NewLotStatus.failure,
            errorType: NewLotErrorType.submission,
            errorMessage: 'Quantity must be at least 1',
          ),
        );
        return;
      }
    } else if (state.weightKg < 0.1) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.submission,
          errorMessage: 'Weight must be at least 0.1 KG',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: NewLotStatus.submitting,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    try {
      final imagePaths =
          (state.imagePath != null && state.imagePath!.isNotEmpty)
          ? [state.imagePath!]
          : const <String>[];

      final params = CreateLotParams(
        imagePaths: imagePaths,
        estimatedWeight: state.weightKg,
        location: event.location,
        estimatedPrice: state.priceEstimate?.estimatedValueInr,
        category: state.category,
        subCategory: event.subCategory,
        description: event.description,
        materialId: event.materialId,
        state: event.state ?? event.location.state,
        city: event.city ?? event.location.city,
        quantity: state.quantity,
      );

      final lot = await createCollectorLotUseCase(params);

      emit(
        state.copyWith(
          status: NewLotStatus.success,
          createdLot: lot,
          errorType: NewLotErrorType.none,
          clearErrorMessage: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.submission,
          errorMessage: e.message,
          lastException: e,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.submission,
          errorMessage: 'Lot submission failed: ${e.toString()}',
        ),
      );
    }
  }

  void _onReset(NewLotReset event, Emitter<NewLotState> emit) {
    _pricingRequestId++;
    emit(const NewLotState());
  }
}
