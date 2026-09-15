import '../../core/network/api_client.dart';
import '../../data/datasources/remote/lots_remote_data_source.dart';
import '../../data/datasources/remote/matchmaking_remote_data_source.dart';
import '../../data/datasources/remote/materials_remote_data_source.dart';
import '../../data/datasources/remote/ml_remote_data_source.dart';
import '../../data/repositories/collector_lots_repository_impl.dart';
import '../../data/repositories/matchmaking_repository_impl.dart';
import '../../data/repositories/materials_repository_impl.dart';
import '../../data/repositories/ml_repository_impl.dart';
import '../../domain/repositories/collector_lots_repository.dart';
import '../../domain/repositories/matchmaking_repository.dart';
import '../../domain/repositories/materials_repository.dart';
import '../../domain/repositories/ml_repository.dart';
import '../../domain/usecases/collector/classify_scrap_image_usecase.dart';
import '../../domain/usecases/collector/create_collector_lot_usecase.dart';
import '../../domain/usecases/collector/estimate_price_usecase.dart';
import '../../domain/usecases/collector/get_collector_lots_usecase.dart';
import '../../domain/usecases/collector/get_live_scrap_rates_usecase.dart';
import '../../domain/usecases/collector/get_lot_details_usecase.dart';
import '../../domain/usecases/collector/get_matched_recyclers_usecase.dart';
import 'presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'presentation/bloc/matchmaking/matchmaking_bloc.dart';
import 'presentation/bloc/new_lot/new_lot_bloc.dart';

class CollectorDependencyContainer {
  final MLRepository mlRepository;
  final MaterialsRepository materialsRepository;
  final MatchmakingRepository matchmakingRepository;
  final CollectorLotsRepository collectorLotsRepository;

  // Domain use cases
  late final ClassifyScrapImageUseCase classifyScrapImageUseCase;
  late final EstimatePriceUseCase estimatePriceUseCase;
  late final CreateCollectorLotUseCase createCollectorLotUseCase;
  late final GetMatchedRecyclersUseCase getMatchedRecyclersUseCase;
  late final GetCollectorLotsUseCase getCollectorLotsUseCase;
  late final GetLotDetailsUseCase getLotDetailsUseCase;
  late final GetLiveScrapRatesUseCase getLiveScrapRatesUseCase;

  CollectorDependencyContainer({
    required this.mlRepository,
    required this.materialsRepository,
    required this.matchmakingRepository,
    required this.collectorLotsRepository,
  }) {
    classifyScrapImageUseCase = ClassifyScrapImageUseCase(mlRepository);
    estimatePriceUseCase = EstimatePriceUseCase(mlRepository);
    createCollectorLotUseCase = CreateCollectorLotUseCase(
      collectorLotsRepository,
    );
    getMatchedRecyclersUseCase = GetMatchedRecyclersUseCase(
      matchmakingRepository,
    );
    getCollectorLotsUseCase = GetCollectorLotsUseCase(collectorLotsRepository);
    getLotDetailsUseCase = GetLotDetailsUseCase(collectorLotsRepository);
    getLiveScrapRatesUseCase = GetLiveScrapRatesUseCase(materialsRepository);
  }

  factory CollectorDependencyContainer.fromApiClient(ApiClient apiClient) {
    return CollectorDependencyContainer(
      mlRepository: MLRepositoryImpl(
        remoteDataSource: MLRemoteDataSourceImpl(apiClient: apiClient),
      ),
      materialsRepository: MaterialsRepositoryImpl(
        remoteDataSource: MaterialsRemoteDataSourceImpl(apiClient: apiClient),
      ),
      matchmakingRepository: MatchmakingRepositoryImpl(
        remoteDataSource: MatchmakingRemoteDataSourceImpl(apiClient: apiClient),
      ),
      collectorLotsRepository: CollectorLotsRepositoryImpl(
        remoteDataSource: LotsRemoteDataSourceImpl(apiClient: apiClient),
      ),
    );
  }

  NewLotBloc createNewLotBloc() => NewLotBloc(
    classifyScrapImageUseCase: classifyScrapImageUseCase,
    estimatePriceUseCase: estimatePriceUseCase,
    createCollectorLotUseCase: createCollectorLotUseCase,
  );

  MatchmakingBloc createMatchmakingBloc() =>
      MatchmakingBloc(getMatchedRecyclersUseCase: getMatchedRecyclersUseCase);

  CollectorLotsBloc createCollectorLotsBloc() => CollectorLotsBloc(
    getCollectorLotsUseCase: getCollectorLotsUseCase,
    getLotDetailsUseCase: getLotDetailsUseCase,
    getLiveScrapRatesUseCase: getLiveScrapRatesUseCase,
  );
}
