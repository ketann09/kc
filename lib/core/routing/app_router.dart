import 'package:flutter/material.dart';
import 'package:kabadiwala_connect/features/collector/new_scrap_lot_screen.dart';
import 'package:kabadiwala_connect/features/collector/transaction_created_screen.dart';

import '../../features/collector/nearby_recyclers_screen.dart';
import '../../features/onboarding/city_selection_screen.dart';
import '../../features/onboarding/otp_screen.dart';
import '../../features/onboarding/role_selection_screen.dart';
import '../../features/onboarding/state_selection_screen.dart';
import '../../features/collector/collector_dashboard_screen.dart';
import '../../features/collector/accept_offer_screen.dart';
import '../../features/recycler/incoming_lot_screen.dart';
import '../../features/recycler/recycler_dashboard_screen.dart';
import '../../features/recycler/recycler_lot_details_screen.dart';
import '../../features/authentication/presentation/auth_gate.dart';

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

      case '/collector-dashboard':
        return MaterialPageRoute(
          builder: (_) => const CollectorDashboardScreen(),
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

      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
