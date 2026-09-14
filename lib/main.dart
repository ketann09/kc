import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/storage/auth_token_storage.dart';
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
  const KabadiwalaConnectApp({super.key});

  @override
  State<KabadiwalaConnectApp> createState() => _KabadiwalaConnectAppState();
}

class _KabadiwalaConnectAppState extends State<KabadiwalaConnectApp> {
  late final ApiClient _apiClient;
  late final AuthTokenStorage _tokenStorage;
  late final AuthRemoteDataSource _remoteDataSource;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _tokenStorage = SharedPreferencesAuthTokenStorage();
    _remoteDataSource = AuthRemoteDataSourceImpl(apiClient: _apiClient);
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      tokenStorage: _tokenStorage,
      apiClient: _apiClient,
    );
    _authBloc = AuthBloc(authRepository: _authRepository)
      ..add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
      ],
      child: BlocProvider.value(
        value: _authBloc,
        child: MaterialApp(
          title: 'Kabadiwala Connect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
