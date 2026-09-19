import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/bloc/accessibility/accessibility_bloc.dart';
import 'package:kabadiwala_connect/core/localization/app_language.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/translations/english_translations.dart';
import 'package:kabadiwala_connect/core/localization/translations/hindi_translations.dart';
import 'package:kabadiwala_connect/core/localization/translations/marathi_translations.dart';
import 'package:kabadiwala_connect/core/network/api_exception.dart';
import 'package:kabadiwala_connect/core/services/connectivity_service.dart';
import 'package:kabadiwala_connect/core/widgets/offline_blocked_sheet.dart';
import 'package:kabadiwala_connect/core/widgets/speaker_button.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';
import 'package:kabadiwala_connect/domain/entities/transaction_entity.dart';
import 'package:kabadiwala_connect/domain/entities/user_entity.dart';
import 'package:kabadiwala_connect/domain/entities/auth_session_entity.dart';
import 'package:kabadiwala_connect/domain/repositories/auth_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/recycler_lots_repository.dart';
import 'package:kabadiwala_connect/domain/repositories/transactions_repository.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/accept_recycler_lot_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/get_recycler_lot_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/recycler/update_lot_lifecycle_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/create_transaction_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/get_transaction_by_id_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_handover_details_usecase.dart';
import 'package:kabadiwala_connect/domain/usecases/transactions/update_payment_status_usecase.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:kabadiwala_connect/features/authentication/presentation/bloc/auth_state.dart';
import 'package:kabadiwala_connect/features/onboarding/register_screen.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'package:kabadiwala_connect/features/recycler/presentation/bloc/lot_details/recycler_lot_details_state.dart';
import 'package:kabadiwala_connect/features/recycler/recycler_lot_details_screen.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:kabadiwala_connect/features/transactions/presentation/screens/transaction_details_screen.dart';

// ----------------------------------------------------------------------
// Test Fakes & Mock Services
// ----------------------------------------------------------------------

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthSessionEntity> login({
    required String phoneNumber,
    required String password,
  }) async {
    return const AuthSessionEntity(
      user: UserEntity(
        id: 'u1',
        fullName: 'Test User',
        phoneNumber: '9876543210',
        role: UserRole.collector,
      ),
      accessToken: 'token',
      refreshToken: 'refresh',
    );
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) async {
    return UserEntity(
      id: 'u1',
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async => const UserEntity(
        id: 'u1',
        fullName: 'Test User',
        phoneNumber: '9876543210',
        role: UserRole.collector,
      );

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshAccessToken() async => 'token';

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;
}

class MockRecyclerLotsRepository implements RecyclerLotsRepository {
  LotEntity? lot;

  @override
  Future<List<LotEntity>> getRecyclerLots({
    int page = 1,
    int limit = 10,
    String? status,
  }) async =>
      [];

  @override
  Future<LotEntity> getLotById(String lotId) async => lot!;

  @override
  Future<LotEntity> acceptLot({required String lotId, double? price}) async =>
      lot!;

  @override
  Future<LotEntity> updateLotLifecycle({
    required String lotId,
    required String status,
    double? actualWeight,
    double? finalPrice,
  }) async =>
      lot!;
}

class MockTransactionsRepository implements TransactionsRepository {
  TransactionEntity? txn;

  @override
  Future<TransactionEntity> createTransaction({
    required String lotId,
    required String paymentMethod,
    required double amount,
    double? actualWeight,
    double? estimatedWeight,
    String? notes,
  }) async =>
      txn!;

  @override
  Future<TransactionEntity> getTransactionById(String transactionId) async =>
      txn!;

  @override
  Future<List<TransactionEntity>> getRecyclerTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async =>
      [];

  @override
  Future<List<TransactionEntity>> getCollectorTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async =>
      [];

  @override
  Future<TransactionEntity> updateHandoverDetails({
    required String transactionId,
    List<String>? handoverPhotos,
    double? latitude,
    double? longitude,
    String? receivedBy,
    String? verifiedBy,
  }) async =>
      txn!;

  @override
  Future<TransactionEntity> updatePaymentStatus({
    required String transactionId,
    required String paymentStatus,
    String? paymentTransactionId,
    String? receiptUrl,
  }) async =>
      txn!;
}

class MockConnectivityService implements ConnectivityService {
  bool _isOnline;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  int checkConnectionCallCount = 0;
  bool nextCheckResult;

  MockConnectivityService({bool initialOnline = false, bool? nextCheckResult})
      : _isOnline = initialOnline,
        nextCheckResult = nextCheckResult ?? initialOnline;

  @override
  bool get isOnline => _isOnline;

  void setOnline(bool value) {
    _isOnline = value;
    _controller.add(value);
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> checkConnection() async {
    checkConnectionCallCount++;
    _isOnline = nextCheckResult;
    _controller.add(nextCheckResult);
    return nextCheckResult;
  }

  @override
  void recordTelemetry({required bool isSuccess, ApiException? exception}) {
    if (isSuccess) {
      _isOnline = true;
    } else if (exception != null && (exception.isNetworkError || exception.isTimeout)) {
      _isOnline = false;
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

Widget createTestApp({
  required Widget child,
  AppLanguage language = AppLanguage.hindi,
  ConnectivityService? connectivityService,
  AccessibilityBloc? accessibilityBloc,
  AuthBloc? authBloc,
  RecyclerLotDetailsBloc? recyclerLotDetailsBloc,
  TransactionDetailsBloc? transactionDetailsBloc,
}) {
  Widget current = child;

  final blocProviders = <BlocProvider>[
    if (accessibilityBloc != null)
      BlocProvider<AccessibilityBloc>.value(value: accessibilityBloc),
    if (authBloc != null)
      BlocProvider<AuthBloc>.value(value: authBloc),
    if (recyclerLotDetailsBloc != null)
      BlocProvider<RecyclerLotDetailsBloc>.value(value: recyclerLotDetailsBloc),
    if (transactionDetailsBloc != null)
      BlocProvider<TransactionDetailsBloc>.value(value: transactionDetailsBloc),
  ];

  if (blocProviders.isNotEmpty) {
    current = MultiBlocProvider(
      providers: blocProviders,
      child: current,
    );
  }

  current = AppLocalizationsWidget(
    language: language,
    child: MaterialApp(
      home: Scaffold(body: current),
    ),
  );

  if (connectivityService != null) {
    current = RepositoryProvider<ConnectivityService>.value(
      value: connectivityService,
      child: current,
    );
  }

  return current;
}

void main() {
  group('Task 5.9D — OfflineBlockedSheet Component Tests', () {
    testWidgets('Renders low-literacy vernacular explanation, icon, and buttons', (tester) async {
      final mockConnectivity = MockConnectivityService(initialOnline: false);

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          language: AppLanguage.hindi,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                OfflineBlockedSheet.show(
                  context,
                  action: OfflineBlockedAction.createLot,
                  connectivityService: mockConnectivity,
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify offline title
      expect(find.text('आप अभी ऑफलाइन हैं'), findsOneWidget);

      // Verify mutation-specific Hindi explanation
      expect(
        find.text('नया कबाड़ लॉट इंटरनेट आने के बाद ही बनाया जा सकता है।'),
        findsOneWidget,
      );

      // Verify guidance help text
      expect(
        find.text('कृपया अपना मोबाइल डेटा या वाई-फाई चालू करें और पुनः प्रयास करें।'),
        findsOneWidget,
      );

      // Verify SpeakerButton is rendered
      expect(find.byType(SpeakerButton), findsOneWidget);

      // Verify primary CTA button min height 56dp
      final primaryButtonFinder =
          find.widgetWithText(ElevatedButton, 'इंटरनेट कनेक्शन जांचें');
      expect(primaryButtonFinder, findsOneWidget);
      final primarySize = tester.getSize(primaryButtonFinder);
      expect(primarySize.height, greaterThanOrEqualTo(56.0));

      // Verify secondary dismiss button min height 48dp
      final dismissButtonFinder = find.byType(TextButton);
      expect(dismissButtonFinder, findsOneWidget);
      final dismissSize = tester.getSize(dismissButtonFinder);
      expect(dismissSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Check Connection button probes connectivity and displays still offline when unreachable', (tester) async {
      final mockConnectivity = MockConnectivityService(
        initialOnline: false,
        nextCheckResult: false,
      );

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          language: AppLanguage.hindi,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                OfflineBlockedSheet.show(
                  context,
                  action: OfflineBlockedAction.register,
                  connectivityService: mockConnectivity,
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Check Connection button
      await tester.tap(find.widgetWithText(ElevatedButton, 'इंटरनेट कनेक्शन जांचें'));
      await tester.pump();

      // Verify probe was called
      expect(mockConnectivity.checkConnectionCallCount, equals(1));
      await tester.pumpAndSettle();

      // Verify still offline feedback message is shown
      expect(find.text('अभी भी ऑफलाइन हैं। कृपया नेटवर्क चालू करें।'), findsOneWidget);
    });

    testWidgets('Check Connection button closes sheet and calls onRetry when connectivity restored', (tester) async {
      final mockConnectivity = MockConnectivityService(
        initialOnline: false,
        nextCheckResult: true,
      );
      bool retryCalled = false;

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          language: AppLanguage.hindi,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                OfflineBlockedSheet.show(
                  context,
                  action: OfflineBlockedAction.generic,
                  connectivityService: mockConnectivity,
                  onRetry: () {
                    retryCalled = true;
                  },
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Check Connection button
      await tester.tap(find.widgetWithText(ElevatedButton, 'इंटरनेट कनेक्शन जांचें'));
      await tester.pump();

      expect(mockConnectivity.checkConnectionCallCount, equals(1));
      await tester.pumpAndSettle();

      // Verify connection restored message was shown and onRetry was called
      expect(retryCalled, isTrue);
      // Sheet should be popped
      expect(find.byType(OfflineBlockedSheet), findsNothing);
    });
  });

  group('Task 5.9D — Localization & Vernacular Parity Tests', () {
    test('All 17 offline strings are defined in Hindi, Marathi, and English', () {
      const hindi = HindiTranslations();
      const marathi = MarathiTranslations();
      const english = EnglishTranslations();

      // Title & Subtitle & Help
      expect(hindi.offlineNoticeTitle.isNotEmpty, isTrue);
      expect(marathi.offlineNoticeTitle.isNotEmpty, isTrue);
      expect(english.offlineNoticeTitle.isNotEmpty, isTrue);

      expect(hindi.offlineNoticeSubtitle.isNotEmpty, isTrue);
      expect(marathi.offlineNoticeSubtitle.isNotEmpty, isTrue);
      expect(english.offlineNoticeSubtitle.isNotEmpty, isTrue);

      expect(hindi.offlineActionHelp.isNotEmpty, isTrue);
      expect(marathi.offlineActionHelp.isNotEmpty, isTrue);
      expect(english.offlineActionHelp.isNotEmpty, isTrue);

      // Probe actions
      expect(hindi.checkConnectionAction.isNotEmpty, isTrue);
      expect(marathi.checkConnectionAction.isNotEmpty, isTrue);
      expect(english.checkConnectionAction.isNotEmpty, isTrue);

      expect(hindi.connectionChecking.isNotEmpty, isTrue);
      expect(marathi.connectionChecking.isNotEmpty, isTrue);
      expect(english.connectionChecking.isNotEmpty, isTrue);

      expect(hindi.connectionStillOffline.isNotEmpty, isTrue);
      expect(marathi.connectionStillOffline.isNotEmpty, isTrue);
      expect(english.connectionStillOffline.isNotEmpty, isTrue);

      expect(hindi.connectionRestored.isNotEmpty, isTrue);
      expect(marathi.connectionRestored.isNotEmpty, isTrue);
      expect(english.connectionRestored.isNotEmpty, isTrue);

      // All 10 mutation actions
      expect(hindi.offlineCreateLotBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineCreateLotBlocked.isNotEmpty, isTrue);
      expect(english.offlineCreateLotBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineConfirmOfferBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineConfirmOfferBlocked.isNotEmpty, isTrue);
      expect(english.offlineConfirmOfferBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineAcceptLotBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineAcceptLotBlocked.isNotEmpty, isTrue);
      expect(english.offlineAcceptLotBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineMarkPickedBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineMarkPickedBlocked.isNotEmpty, isTrue);
      expect(english.offlineMarkPickedBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineMarkDeliveredBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineMarkDeliveredBlocked.isNotEmpty, isTrue);
      expect(english.offlineMarkDeliveredBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineCompleteLotBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineCompleteLotBlocked.isNotEmpty, isTrue);
      expect(english.offlineCompleteLotBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineCreateTransactionBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineCreateTransactionBlocked.isNotEmpty, isTrue);
      expect(english.offlineCreateTransactionBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineUpdateHandoverBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineUpdateHandoverBlocked.isNotEmpty, isTrue);
      expect(english.offlineUpdateHandoverBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineUpdatePaymentBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineUpdatePaymentBlocked.isNotEmpty, isTrue);
      expect(english.offlineUpdatePaymentBlocked.isNotEmpty, isTrue);

      expect(hindi.offlineRegisterBlocked.isNotEmpty, isTrue);
      expect(marathi.offlineRegisterBlocked.isNotEmpty, isTrue);
      expect(english.offlineRegisterBlocked.isNotEmpty, isTrue);
    });
  });

  group('Task 5.9D — Mutation Pre-flight & Race Condition Unit & Widget Tests', () {
    testWidgets('M10: RegisterScreen pre-flight blocks registration when offline and preserves inputs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockConnectivity = MockConnectivityService(initialOnline: false);
      final authRepo = MockAuthRepository();
      final authBloc = AuthBloc(authRepository: authRepo);
      addTearDown(authBloc.close);

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          authBloc: authBloc,
          language: AppLanguage.hindi,
          child: const RegisterScreen(
            role: 'collector',
            state: 'उत्तर प्रदेश',
            city: 'गाज़ियाबाद',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter form inputs
      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'राम कुमार',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('register_pincode_field')),
        '201001',
      );

      // Tap Register button
      final registerButton = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // OfflineBlockedSheet must appear with M10 explanation
      expect(find.byType(OfflineBlockedSheet), findsOneWidget);
      expect(
        find.text('नया खाता बनाने के लिए इंटरनेट कनेक्शन आवश्यक है।'),
        findsOneWidget,
      );

      // Dismiss sheet
      await tester.tap(find.widgetWithText(TextButton, 'पीछे'));
      await tester.pumpAndSettle();

      // Verify form inputs remain 100% intact
      expect(find.text('राम कुमार'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('M10: RegisterScreen handles in-flight network drop gracefully via OfflineBlockedSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockConnectivity = MockConnectivityService(initialOnline: false);
      final authRepo = MockAuthRepository();
      final authBloc = AuthBloc(authRepository: authRepo);
      addTearDown(authBloc.close);

      // Provide AuthBloc that emits AuthFailure with network ApiException
      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          authBloc: authBloc,
          language: AppLanguage.hindi,
          child: const RegisterScreen(
            role: 'collector',
            state: 'उत्तर प्रदेश',
            city: 'गाज़ियाबाद',
          ),
        ),
      );
      await tester.pumpAndSettle();

      authBloc.emit(
        AuthFailure(
          'Network connection timeout',
          lastException: ApiException.network(),
        ),
      );
      await tester.pumpAndSettle();

      // OfflineBlockedSheet must appear
      expect(find.byType(OfflineBlockedSheet), findsOneWidget);
      expect(
        find.text('नया खाता बनाने के लिए इंटरनेट कनेक्शन आवश्यक है।'),
        findsOneWidget,
      );
    });

    testWidgets('M10: 4xx business error (409) does NOT trigger OfflineBlockedSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockConnectivity = MockConnectivityService(initialOnline: true);
      final authRepo = MockAuthRepository();
      final authBloc = AuthBloc(authRepository: authRepo);
      addTearDown(authBloc.close);

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          authBloc: authBloc,
          language: AppLanguage.hindi,
          child: const RegisterScreen(
            role: 'collector',
            state: 'उत्तर प्रदेश',
            city: 'गाज़ियाबाद',
          ),
        ),
      );
      await tester.pumpAndSettle();

      authBloc.emit(
        const AuthFailure('इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है'),
      );
      await tester.pumpAndSettle();

      // OfflineBlockedSheet must NOT appear
      expect(find.byType(OfflineBlockedSheet), findsNothing);

      // SnackBar with the Hindi business error must appear
      expect(
        find.text('इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है'),
        findsOneWidget,
      );
    });

    testWidgets('M3-M6: RecyclerLotDetailsScreen blocks lifecycle mutation when offline', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockConnectivity = MockConnectivityService(initialOnline: false);

      final testLot = LotEntity(
        id: 'lot-123',
        collectorId: 'col-123',
        status: LotStatus.accepted,
        estimatedWeight: 50.0,
        estimatedPrice: 1500.0,
        location: const LotLocationEntity(
          address: 'गली 4',
          city: 'गाजियाबाद',
          state: 'उत्तर प्रदेश',
        ),
        createdAt: DateTime.now(),
        collectorName: 'राजेश',
        collectorPhone: '9876543210',
        materialName: 'प्लास्टिक',
        description: 'PET बॉटल',
      );

      final fakeRepo = MockRecyclerLotsRepository();
      fakeRepo.lot = testLot;
      final bloc = RecyclerLotDetailsBloc(
        getRecyclerLotDetailsUseCase: GetRecyclerLotDetailsUseCase(fakeRepo),
        acceptRecyclerLotUseCase: AcceptRecyclerLotUseCase(fakeRepo),
        updateLotLifecycleUseCase: UpdateLotLifecycleUseCase(fakeRepo),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          recyclerLotDetailsBloc: bloc,
          language: AppLanguage.hindi,
          child: RecyclerLotDetailsScreen(lotId: testLot.id),
        ),
      );
      await tester.pumpAndSettle();

      bloc.emit(RecyclerLotDetailsLoaded(testLot));
      await tester.pumpAndSettle();

      // When lot status is accepted, next CTA is "पिकअप के लिए चिह्नित करें"
      final actionButton = find.widgetWithText(ElevatedButton, 'पिकअप के लिए चिह्नित करें');
      expect(actionButton, findsOneWidget);

      await tester.tap(actionButton);
      await tester.pumpAndSettle();

      // OfflineBlockedSheet must appear immediately without showing confirmation dialog
      expect(find.byType(OfflineBlockedSheet), findsOneWidget);
      expect(
        find.text('लॉट पिकअप चिह्नित करने के लिए इंटरनेट आवश्यक है।'),
        findsOneWidget,
      );
    });

    testWidgets('M7-M9: TransactionDetailsScreen blocks payment update when offline', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockConnectivity = MockConnectivityService(initialOnline: false);

      final testTxn = TransactionEntity(
        id: 'txn-123',
        lotId: 'lot-123',
        collectorId: 'col-1',
        recyclerId: 'rec-1',
        amount: 2500.0,
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final fakeRepo = MockTransactionsRepository();
      fakeRepo.txn = testTxn;
      final bloc = TransactionDetailsBloc(
        createTransactionUseCase: CreateTransactionUseCase(fakeRepo),
        getTransactionByIdUseCase: GetTransactionByIdUseCase(fakeRepo),
        updateHandoverDetailsUseCase: UpdateHandoverDetailsUseCase(fakeRepo),
        updatePaymentStatusUseCase: UpdatePaymentStatusUseCase(fakeRepo),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        createTestApp(
          connectivityService: mockConnectivity,
          transactionDetailsBloc: bloc,
          language: AppLanguage.hindi,
          child: TransactionDetailsScreen(
            transactionId: testTxn.id,
            initialTransaction: testTxn,
            isRecycler: true,
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap payment update button
      final payButton = find.widgetWithText(ElevatedButton, 'भुगतान दर्ज करें');
      expect(payButton, findsOneWidget);
      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // In payment modal, tap submit
      final submitButton = find.widgetWithText(ElevatedButton, 'पुष्टि करें एवं सहेजें');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // OfflineBlockedSheet must appear
      expect(find.byType(OfflineBlockedSheet), findsOneWidget);
      expect(
        find.text('भुगतान स्थिति अपडेट करने के लिए इंटरनेट आवश्यक है।'),
        findsOneWidget,
      );
    });
  });
}
