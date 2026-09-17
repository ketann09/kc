import '../../core/network/api_client.dart';
import '../../data/datasources/remote/lots_remote_data_source.dart';
import '../../data/repositories/recycler_lots_repository_impl.dart';
import '../../domain/repositories/recycler_lots_repository.dart';
import '../../domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import '../../domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import '../../domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'presentation/bloc/recycler_dashboard_bloc.dart';

class RecyclerDependencyContainer {
  final RecyclerLotsRepository recyclerLotsRepository;
  late final GetRecyclerLotsUseCase getRecyclerLotsUseCase;
  late final GetRecyclerLotDetailsUseCase getRecyclerLotDetailsUseCase;
  late final AcceptRecyclerLotUseCase acceptRecyclerLotUseCase;

  RecyclerDependencyContainer({required this.recyclerLotsRepository}) {
    getRecyclerLotsUseCase = GetRecyclerLotsUseCase(recyclerLotsRepository);
    getRecyclerLotDetailsUseCase = GetRecyclerLotDetailsUseCase(
      recyclerLotsRepository,
    );
    acceptRecyclerLotUseCase = AcceptRecyclerLotUseCase(recyclerLotsRepository);
  }

  factory RecyclerDependencyContainer.fromApiClient(ApiClient apiClient) {
    return RecyclerDependencyContainer(
      recyclerLotsRepository: RecyclerLotsRepositoryImpl(
        remoteDataSource: LotsRemoteDataSourceImpl(apiClient: apiClient),
      ),
    );
  }

  RecyclerDashboardBloc createRecyclerDashboardBloc() =>
      RecyclerDashboardBloc(getRecyclerLotsUseCase: getRecyclerLotsUseCase);

  RecyclerLotDetailsBloc createRecyclerLotDetailsBloc() =>
      RecyclerLotDetailsBloc(
        getRecyclerLotDetailsUseCase: getRecyclerLotDetailsUseCase,
        acceptRecyclerLotUseCase: acceptRecyclerLotUseCase,
      );
}
