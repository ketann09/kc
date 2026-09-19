import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bloc/accessibility/accessibility_bloc.dart';
import 'core/bloc/accessibility/accessibility_event.dart';
import 'core/bloc/accessibility/accessibility_state.dart';
import 'core/bloc/network/network_cubit.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/tts_service.dart';
import 'core/storage/accessibility_preferences_storage.dart';
import 'core/storage/auth_token_storage.dart';
import 'core/storage/read_cache_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KabadiwalaConnectApp());
}

class KabadiwalaConnectApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final AccessibilityPreferencesStorage? accessibilityStorage;
  final TtsService? ttsService;
  final ConnectivityService? connectivityService;
  final NetworkCubit? networkCubit;
  final ReadCacheStorage? readCacheStorage;

  const KabadiwalaConnectApp({
    super.key,
    this.authRepository,
    this.accessibilityStorage,
    this.ttsService,
    this.connectivityService,
    this.networkCubit,
    this.readCacheStorage,
  });

  @override
  State<KabadiwalaConnectApp> createState() => _KabadiwalaConnectAppState();
}

class _KabadiwalaConnectAppState extends State<KabadiwalaConnectApp> {
  late final ApiClient _apiClient;
  late final AuthTokenStorage _tokenStorage;
  late final ReadCacheStorage _readCacheStorage;
  late final AuthRemoteDataSource _remoteDataSource;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final AccessibilityPreferencesStorage _accessibilityStorage;
  late final TtsService _ttsService;
  late final AccessibilityBloc _accessibilityBloc;
  late final ConnectivityService _connectivityService;
  late final NetworkCubit _networkCubit;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _tokenStorage = SharedPreferencesAuthTokenStorage();
    _readCacheStorage =
        widget.readCacheStorage ?? SharedPreferencesReadCacheStorage();
    _remoteDataSource = AuthRemoteDataSourceImpl(apiClient: _apiClient);
    _authRepository = widget.authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: _remoteDataSource,
          tokenStorage: _tokenStorage,
          apiClient: _apiClient,
        );
    _authBloc = AuthBloc(authRepository: _authRepository)
      ..add(const AuthCheckRequested());

    _accessibilityStorage =
        widget.accessibilityStorage ?? SharedPreferencesAccessibilityStorage();
    _ttsService = widget.ttsService ?? FlutterTtsServiceImpl();
    _accessibilityBloc = AccessibilityBloc(
      storage: _accessibilityStorage,
      ttsService: _ttsService,
    )..add(const AccessibilityInitialized());

    _connectivityService = widget.connectivityService ??
        DefaultConnectivityService(apiClient: _apiClient);
    _networkCubit = widget.networkCubit ??
        NetworkCubit(connectivityService: _connectivityService);
  }

  @override
  void dispose() {
    _authBloc.close();
    _accessibilityBloc.close();
    _networkCubit.close();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<AccessibilityPreferencesStorage>.value(
            value: _accessibilityStorage),
        RepositoryProvider<TtsService>.value(value: _ttsService),
        RepositoryProvider<ConnectivityService>.value(
            value: _connectivityService),
        RepositoryProvider<ReadCacheStorage>.value(value: _readCacheStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _accessibilityBloc),
          BlocProvider.value(value: _networkCubit),
        ],
        child: BlocBuilder<AccessibilityBloc, AccessibilityState>(
          builder: (context, accessState) {
            return AppLocalizationsWidget(
              language: accessState.language,
              child: MaterialApp(
                title: 'Kabadiwala Connect',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                initialRoute: '/',
                onGenerateRoute: AppRouter.generateRoute,
              ),
            );
          },
        ),
      ),
    );
  }
}
