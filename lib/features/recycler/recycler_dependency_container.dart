import '../../core/network/api_client.dart';
import '../../data/datasources/remote/lots_remote_data_source.dart';
import '../../data/repositories/recycler_lots_repository_impl.dart';
import '../../domain/repositories/recycler_lots_repository.dart';
import '../../domain/usecases/recycler/get_recycler_lots_usecase.dart';
import 'presentation/bloc/recycler_dashboard_bloc.dart';

class RecyclerDependencyContainer {
  final RecyclerLotsRepository recyclerLotsRepository;
  late final GetRecyclerLotsUseCase getRecyclerLotsUseCase;

  RecyclerDependencyContainer({required this.recyclerLotsRepository}) {
    getRecyclerLotsUseCase = GetRecyclerLotsUseCase(recyclerLotsRepository);
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
}
