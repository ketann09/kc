import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/language_audio_sheet.dart';
import '../../core/widgets/speaker_button.dart';
import '../../domain/entities/user_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_event.dart';
import '../authentication/presentation/bloc/auth_state.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final l10n = context.l10n;
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterValidPhone),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordMinLength),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(phoneNumber: mobile, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        } else if (state is Authenticated) {
          if (state.user.role == UserRole.collector) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/collector-dashboard',
              (route) => false,
            );
          } else if (state.user.role == UserRole.recycler) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/recycler-dashboard',
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('एडमिन खाता: कृपया वेब पोर्टल का उपयोग करें'),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 31),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Top Accessibility Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => LanguageAudioSheet.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language,
                                  size: 18, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 6),
                              Text(
                                context.currentLanguage.nativeLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SpeakerButton(
                        textToSpeak:
                            '${l10n.loginSubtitle}. ${l10n.loginTitle}. ${l10n.enterMobile}.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Greeting
                  Text(
                    l10n.loginSubtitle,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Heading
                  Text(
                    l10n.loginTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text(
                    l10n.enterMobile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mobile number field
                  Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),

                        const Icon(
                          Icons.phone_android_outlined,
                          color: Color(0xFF087F68),
                          size: 24,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            enabled: !isLoading,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.mobileHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFF858585),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.enterPassword,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password field
                  Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),

                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF087F68),
                          size: 24,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !isLoading,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.passwordHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFF858585),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF858585),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),

                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF147A65),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        disabledBackgroundColor: const Color(0xFF147A65)
                            .withValues(alpha: 0.6),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.loginAction,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link to onboarding flow
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/role');
                            },
                      child: Text(
                        l10n.createNewAccount,
                        style: const TextStyle(
                          color: Color(0xFF147A65),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
