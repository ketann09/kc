import 'package:flutter/material.dart';

import '../../features/onboarding/role_selection_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        );
    }
  }
}