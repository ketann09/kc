import 'package:flutter/material.dart';
import 'package:kabadiwala_connect/features/collector/new_scrap_lot_screen.dart';
import 'package:kabadiwala_connect/features/collector/transaction_created_screen.dart';

import '../../features/collector/nearby_recyclers_screen.dart';
import '../../features/onboarding/city_selection_screen.dart';
import '../../features/onboarding/otp_screen.dart';
import '../../features/onboarding/register_screen.dart';
import '../../features/onboarding/role_selection_screen.dart';
import '../../features/onboarding/state_selection_screen.dart';
import '../../features/collector/collector_dashboard_screen.dart';
import '../../features/collector/accept_offer_screen.dart';
import '../../features/recycler/incoming_lot_screen.dart';
import '../../features/recycler/recycler_dashboard_screen.dart';
import '../../features/recycler/recycler_lot_details_screen.dart';
import '../../domain/entities/lot_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../features/authentication/presentation/auth_gate.dart';
import '../../features/collector/presentation/screens/collector_lot_details_screen.dart';
import '../../features/collector/presentation/screens/collector_lots_screen.dart';
import '../../features/collector/presentation/screens/collector_transactions_screen.dart';
import '../../features/transactions/presentation/screens/transaction_details_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthGate());

      case '/otp':
        final mobileNumber = settings.arguments as String? ?? '';

        return MaterialPageRoute(
          builder: (_) => OtpScreen(mobileNumber: mobileNumber),
        );

      case '/role':
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case '/state':
        final arguments = settings.arguments as String? ?? 'collector';

        return MaterialPageRoute(
          builder: (_) => StateSelectionScreen(role: arguments),
        );

      case '/city':
        final arguments = settings.arguments as Map<String, dynamic>? ?? {};

        return MaterialPageRoute(
          builder: (_) => CitySelectionScreen(
            role: arguments['role'] as String? ?? 'collector',
            state: arguments['state'] as String? ?? 'उत्तर प्रदेश',
          ),
        );

      case '/register':
        final arguments = settings.arguments as Map<String, dynamic>? ?? {};

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RegisterScreen(
            role: arguments['role'] as String? ?? 'collector',
            state: arguments['state'] as String? ?? 'उत्तर प्रदेश',
            city: arguments['city'] as String? ?? 'गाज़ियाबाद',
          ),
        );

      case '/collector-dashboard':
        return MaterialPageRoute(
          builder: (_) => const CollectorDashboardScreen(),
        );

      case '/collector-transactions':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CollectorTransactionsScreen(),
        );

      case '/collector-lots':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CollectorLotsScreen(),
        );

      case '/collector-lot-details':
        final args = settings.arguments;
        final lotId = args is String
            ? args
            : (args is Map ? args['lotId'] as String? ?? '' : '');
        final lot = args is Map ? args['lot'] as LotEntity? : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              CollectorLotDetailsScreen(lotId: lotId, initialLot: lot),
        );

      case '/new-lot':
        return MaterialPageRoute(builder: (_) => const NewScrapLotScreen());
      case '/recyclers':
        final args = settings.arguments;
        final lotId = args is String
            ? args
            : (args is Map ? args['lotId'] as String? : null);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NearbyRecyclersScreen(lotId: lotId),
        );
      case '/accept-offer':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AcceptOfferScreen(),
        );
      case '/offer-accepted':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'ऑफर स्वीकार किया गया',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      case '/transaction-created':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TransactionCreatedScreen(),
        );
      case '/recycler-dashboard':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RecyclerDashboardScreen(),
        );
      case '/incoming-lot':
      case '/recycler-lot-details':
        final args = settings.arguments;
        if (args is String && args.isNotEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => RecyclerLotDetailsScreen(lotId: args),
          );
        }
        if (args is Map && args['lotId'] is String) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) =>
                RecyclerLotDetailsScreen(lotId: args['lotId'] as String),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const IncomingLotScreen(),
        );

      case '/transaction-details':
        final args = settings.arguments;
        String? transactionId;
        TransactionEntity? initialTransaction;
        String? lotId;
        LotEntity? lot;
        bool isRecycler = true;

        if (args is String) {
          transactionId = args;
        } else if (args is TransactionEntity) {
          initialTransaction = args;
          transactionId = args.id;
        } else if (args is Map) {
          transactionId = args['transactionId'] as String?;
          initialTransaction = args['initialTransaction'] as TransactionEntity?;
          lotId = args['lotId'] as String?;
          lot = args['lot'] as LotEntity?;
          if (args['isRecycler'] is bool) {
            isRecycler = args['isRecycler'] as bool;
          }
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TransactionDetailsScreen(
            transactionId: transactionId,
            initialTransaction: initialTransaction,
            lotId: lotId,
            lot: lot,
            isRecycler: isRecycler,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
