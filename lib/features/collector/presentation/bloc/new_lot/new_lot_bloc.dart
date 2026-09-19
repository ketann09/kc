import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../domain/entities/lot_entity.dart';
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

  Future<void> _onCategoryChanged(
    NewLotCategoryChanged event,
    Emitter<NewLotState> emit,
  ) async {
    emit(
      state.copyWith(
        category: event.category,
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
        category: event.category,
        stateName: event.state!,
        cityName: event.city!,
        weightKg: state.weightKg,
        quantity: state.quantity,
      );
    }
  }

  Future<void> _onWeightQuantityChanged(
    NewLotWeightQuantityChanged event,
    Emitter<NewLotState> emit,
  ) async {
    emit(
      state.copyWith(
        weightKg: event.weightKg,
        quantity: event.quantity,
        errorType: NewLotErrorType.none,
        clearErrorMessage: true,
      ),
    );

    final cat = state.category;
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
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.pricing,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (currentRequestId != _pricingRequestId) return;
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.pricing,
          errorMessage: 'Price estimation failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    NewLotSubmitted event,
    Emitter<NewLotState> emit,
  ) async {
    if (state.status == NewLotStatus.submitting) {
      return;
    }

    if (state.imagePath == null || state.imagePath!.isEmpty) {
      emit(
        state.copyWith(
          status: NewLotStatus.failure,
          errorType: NewLotErrorType.submission,
          errorMessage: 'Please select an image for the lot',
        ),
      );
      return;
    }

    if (state.weightKg < 0.1) {
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
      final params = CreateLotParams(
        imagePaths: [state.imagePath!],
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
