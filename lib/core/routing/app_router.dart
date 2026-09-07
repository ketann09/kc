import 'package:flutter/material.dart';
import 'package:kabadiwala_connect/features/collector/new_scrap_lot_screen.dart';

import '../../features/onboarding/city_selection_screen.dart';
import '../../features/onboarding/mobile_screen.dart';
import '../../features/onboarding/otp_screen.dart';
import '../../features/onboarding/role_selection_screen.dart';
import '../../features/onboarding/state_selection_screen.dart';
import '../../features/collector/collector_dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MobileScreen());

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

      case '/recycler-dashboard':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Recycler dashboard coming next')),
          ),
        );
      case '/new-lot':
        return MaterialPageRoute(builder: (_) => const NewScrapLotScreen());

      default:
        return MaterialPageRoute(builder: (_) => const MobileScreen());
    }
  }
}
