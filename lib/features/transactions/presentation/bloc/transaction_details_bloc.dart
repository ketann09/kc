import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../domain/usecases/transactions/create_transaction_usecase.dart';
import '../../../../domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import '../../../../domain/usecases/transactions/update_handover_details_usecase.dart';
import '../../../../domain/usecases/transactions/update_payment_status_usecase.dart';
import 'transaction_details_event.dart';
import 'transaction_details_state.dart';

class TransactionDetailsBloc
    extends Bloc<TransactionDetailsEvent, TransactionDetailsState> {
  final GetTransactionByIdUseCase getTransactionByIdUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateHandoverDetailsUseCase updateHandoverDetailsUseCase;
  final UpdatePaymentStatusUseCase updatePaymentStatusUseCase;

  TransactionDetailsBloc({
    required this.getTransactionByIdUseCase,
    required this.createTransactionUseCase,
    required this.updateHandoverDetailsUseCase,
    required this.updatePaymentStatusUseCase,
  }) : super(const TransactionDetailsInitial()) {
    on<FetchTransactionDetailsEvent>(_onFetchTransactionDetails);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateHandoverEvent>(_onUpdateHandover);
    on<UpdatePaymentEvent>(_onUpdatePayment);
    on<ResetTransactionActionEvent>(_onResetAction);
  }

  Future<void> _onFetchTransactionDetails(
    FetchTransactionDetailsEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    emit(const TransactionDetailsLoading());
    try {
      final transaction = await getTransactionByIdUseCase(event.transactionId);
      emit(TransactionDetailsLoaded(transaction));
    } on ApiException catch (e) {
      emit(TransactionDetailsFailure(e.message));
    } catch (e) {
      emit(
        TransactionDetailsFailure(
          'लेन-देन विवरण लोड नहीं हो सका: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    emit(const TransactionDetailsLoading());
    try {
      final transaction = await createTransactionUseCase(
        lotId: event.lotId,
        paymentMethod: event.paymentMethod,
        amount: event.amount,
        actualWeight: event.actualWeight,
        estimatedWeight: event.estimatedWeight,
        notes: event.notes,
      );
      emit(
        TransactionDetailsLoaded(
          transaction,
          actionSuccessMessage: 'लेन-देन सफलतापूर्वक बनाया गया',
        ),
      );
    } on ApiException catch (e) {
      emit(TransactionDetailsFailure(e.message));
    } catch (e) {
      emit(
        TransactionDetailsFailure('लेन-देन बनाने में त्रुटि: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateHandover(
    UpdateHandoverEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionDetailsLoaded) return;

    emit(
      currentState.copyWith(
        isSubmittingHandover: true,
        actionSuccessMessage: null,
        actionErrorMessage: null,
      ),
    );

    try {
      final updatedTransaction = await updateHandoverDetailsUseCase(
        transactionId: event.transactionId,
        handoverPhotos: event.handoverPhotos,
        latitude: event.latitude,
        longitude: event.longitude,
        receivedBy: event.receivedBy,
        verifiedBy: event.verifiedBy,
      );
      emit(
        currentState.copyWith(
          transaction: updatedTransaction,
          isSubmittingHandover: false,
          actionSuccessMessage: 'हैंडओवर विवरण सफलतापूर्वक सहेजा गया',
        ),
      );
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          isSubmittingHandover: false,
          actionErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSubmittingHandover: false,
          actionErrorMessage:
              'हैंडओवर विवरण अपडेट करने में विफल: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdatePayment(
    UpdatePaymentEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionDetailsLoaded) return;

    emit(
      currentState.copyWith(
        isSubmittingPayment: true,
        actionSuccessMessage: null,
        actionErrorMessage: null,
      ),
    );

    try {
      final updatedTransaction = await updatePaymentStatusUseCase(
        transactionId: event.transactionId,
        paymentStatus: event.paymentStatus,
        paymentTransactionId: event.paymentTransactionId,
        receiptUrl: event.receiptUrl,
      );
      emit(
        currentState.copyWith(
          transaction: updatedTransaction,
          isSubmittingPayment: false,
          actionSuccessMessage: 'भुगतान स्थिति सफलतापूर्वक अपडेट की गई',
        ),
      );
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          isSubmittingPayment: false,
          actionErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSubmittingPayment: false,
          actionErrorMessage:
              'भुगतान स्थिति अपडेट करने में विफल: ${e.toString()}',
        ),
      );
    }
  }

  void _onResetAction(
    ResetTransactionActionEvent event,
    Emitter<TransactionDetailsState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailsLoaded) {
      emit(
        currentState.copyWith(
          actionSuccessMessage: null,
          actionErrorMessage: null,
        ),
      );
    }
  }
}
