import '../../core/network/api_client.dart';
import '../../data/datasources/remote/lots_remote_data_source.dart';
import '../../data/datasources/remote/transactions_remote_data_source.dart';
import '../../data/repositories/recycler_lots_repository_impl.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../../domain/repositories/recycler_lots_repository.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../../domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import '../../domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import '../../domain/usecases/recycler/get_recycler_lots_usecase.dart';
import '../../domain/usecases/recycler/update_lot_lifecycle_usecase.dart';
import '../../domain/usecases/transactions/create_transaction_usecase.dart';
import '../../domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import '../../domain/usecases/transactions/update_handover_details_usecase.dart';
import '../../domain/usecases/transactions/update_payment_status_usecase.dart';
import '../transactions/presentation/bloc/transaction_details_bloc.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'presentation/bloc/recycler_dashboard_bloc.dart';

class RecyclerDependencyContainer {
  final RecyclerLotsRepository recyclerLotsRepository;
  final TransactionsRepository? transactionsRepository;

  late final GetRecyclerLotsUseCase getRecyclerLotsUseCase;
  late final GetRecyclerLotDetailsUseCase getRecyclerLotDetailsUseCase;
  late final AcceptRecyclerLotUseCase acceptRecyclerLotUseCase;
  late final UpdateLotLifecycleUseCase updateLotLifecycleUseCase;

  late final GetTransactionByIdUseCase? getTransactionByIdUseCase;
  late final CreateTransactionUseCase? createTransactionUseCase;
  late final UpdateHandoverDetailsUseCase? updateHandoverDetailsUseCase;
  late final UpdatePaymentStatusUseCase? updatePaymentStatusUseCase;

  RecyclerDependencyContainer({
    required this.recyclerLotsRepository,
    this.transactionsRepository,
  }) {
    getRecyclerLotsUseCase = GetRecyclerLotsUseCase(recyclerLotsRepository);
    getRecyclerLotDetailsUseCase = GetRecyclerLotDetailsUseCase(
      recyclerLotsRepository,
    );
    acceptRecyclerLotUseCase = AcceptRecyclerLotUseCase(recyclerLotsRepository);
    updateLotLifecycleUseCase = UpdateLotLifecycleUseCase(
      recyclerLotsRepository,
    );

    if (transactionsRepository != null) {
      getTransactionByIdUseCase = GetTransactionByIdUseCase(
        transactionsRepository!,
      );
      createTransactionUseCase = CreateTransactionUseCase(
        transactionsRepository!,
      );
      updateHandoverDetailsUseCase = UpdateHandoverDetailsUseCase(
        transactionsRepository!,
      );
      updatePaymentStatusUseCase = UpdatePaymentStatusUseCase(
        transactionsRepository!,
      );
    }
  }

  factory RecyclerDependencyContainer.fromApiClient(ApiClient apiClient) {
    return RecyclerDependencyContainer(
      recyclerLotsRepository: RecyclerLotsRepositoryImpl(
        remoteDataSource: LotsRemoteDataSourceImpl(apiClient: apiClient),
      ),
      transactionsRepository: TransactionsRepositoryImpl(
        remoteDataSource: TransactionsRemoteDataSourceImpl(
          apiClient: apiClient,
        ),
      ),
    );
  }

  RecyclerDashboardBloc createRecyclerDashboardBloc() =>
      RecyclerDashboardBloc(getRecyclerLotsUseCase: getRecyclerLotsUseCase);

  RecyclerLotDetailsBloc createRecyclerLotDetailsBloc() =>
      RecyclerLotDetailsBloc(
        getRecyclerLotDetailsUseCase: getRecyclerLotDetailsUseCase,
        acceptRecyclerLotUseCase: acceptRecyclerLotUseCase,
        updateLotLifecycleUseCase: updateLotLifecycleUseCase,
      );

  TransactionDetailsBloc createTransactionDetailsBloc() {
    if (transactionsRepository == null ||
        getTransactionByIdUseCase == null ||
        createTransactionUseCase == null ||
        updateHandoverDetailsUseCase == null ||
        updatePaymentStatusUseCase == null) {
      throw StateError('TransactionsRepository is not initialized');
    }
    return TransactionDetailsBloc(
      getTransactionByIdUseCase: getTransactionByIdUseCase!,
      createTransactionUseCase: createTransactionUseCase!,
      updateHandoverDetailsUseCase: updateHandoverDetailsUseCase!,
      updatePaymentStatusUseCase: updatePaymentStatusUseCase!,
    );
  }
}
