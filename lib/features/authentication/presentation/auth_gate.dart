import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../collector/collector_dashboard_screen.dart';
import '../../onboarding/mobile_screen.dart';
import '../../recycler/recycler_dashboard_screen.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          switch (state.user.role) {
            case UserRole.collector:
              return const CollectorDashboardScreen();
            case UserRole.recycler:
              return const RecyclerDashboardScreen();
            case UserRole.admin:
              return const _AdminAccountScreen();
          }
        }

        if (state is AuthInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF147A65)),
            ),
          );
        }

        return const MobileScreen();
      },
    );
  }
}

class _AdminAccountScreen extends StatelessWidget {
  const _AdminAccountScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('एडमिन पोर्टल'),
        backgroundColor: const Color(0xFF147A65),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 80,
                color: Color(0xFF147A65),
              ),
              const SizedBox(height: 24),
              const Text(
                'एडमिन खाता पहचाना गया',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'एडमिन प्रबंधन सुविधाएं वेब पोर्टल पर उपलब्ध हैं। मोबाइल ऐप कलेक्टर और रीसाइक्लर के लिए है।',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF147A65),
                  ),
                  label: const Text(
                    'लॉग आउट करें',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF147A65),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF147A65),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
