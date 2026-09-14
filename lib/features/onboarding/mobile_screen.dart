import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया 10 अंकों का मोबाइल नंबर दर्ज करें'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पासवर्ड कम से कम 6 अक्षरों का होना चाहिए'),
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
                  const SizedBox(height: 50),

                  // Greeting
                  const Text(
                    'नमस्ते!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Heading
                  const Text(
                    'लॉग इन करें',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'अपना मोबाइल नंबर दर्ज करें',
                    style: TextStyle(
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
                            decoration: const InputDecoration(
                              hintText: '10 अंकों का नंबर',
                              hintStyle: TextStyle(
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

                  const Text(
                    'पासवर्ड दर्ज करें',
                    style: TextStyle(
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
                            decoration: const InputDecoration(
                              hintText: 'पासवर्ड',
                              hintStyle: TextStyle(
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'लॉग इन करें',
                                  style: TextStyle(
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
                      child: const Text(
                        'नया खाता बनाएं (रोल चुनें)',
                        style: TextStyle(
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
