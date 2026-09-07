import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KabadiwalaConnectApp());
}

class KabadiwalaConnectApp extends StatelessWidget {
  const KabadiwalaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}