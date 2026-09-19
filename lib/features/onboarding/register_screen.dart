import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/language_audio_sheet.dart';
import '../../core/widgets/speaker_button.dart';
import '../../domain/entities/user_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_event.dart';
import '../authentication/presentation/bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  final String state;
  final String city;

  const RegisterScreen({
    super.key,
    this.role = 'collector',
    this.state = 'उत्तर प्रदेश',
    this.city = 'गाज़ियाबाद',
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _register() {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();
    final pincode = _pincodeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterFullName),
        ),
      );
      return;
    }

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

    if (pincode.isNotEmpty && pincode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pincodeMustBe6Digits),
        ),
      );
      return;
    }

    final userRole = widget.role == 'recycler'
        ? UserRole.recycler
        : UserRole.collector;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        fullName: name,
        phoneNumber: mobile,
        password: password,
        role: userRole,
        address: UserAddressEntity(
          city: widget.city,
          state: widget.state,
          pincode: pincode.isEmpty ? null : pincode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRecycler = widget.role == 'recycler';
    final roleLabel =
        isRecycler ? l10n.recyclerAccountBadge : l10n.collectorAccountBadge;
    final roleIcon = isRecycler ? Icons.factory_outlined : Icons.recycling;

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
          final targetRoute = state.user.role == UserRole.recycler
              ? '/recycler-dashboard'
              : '/collector-dashboard';

          Navigator.pushNamedAndRemoveUntil(
            context,
            targetRoute,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Top bar with Back button, Language switcher, and Speaker button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => LanguageAudioSheet.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                                  size: 16, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 5),
                              Text(
                                context.currentLanguage.nativeLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SpeakerButton(
                        textToSpeak:
                            '${l10n.registerTitle}. $roleLabel. ${l10n.enterMobile}.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l10n.registerTitle,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    context.isMarathi
                        ? 'कबाडीवाला कनेक्ट मध्ये सामील होण्यासाठी माहिती भरा'
                        : context.isEnglish
                            ? 'Enter details to join Kabadiwala Connect'
                            : 'कबाड़ीवाला कनेक्ट में शामिल होने के लिए विवरण दर्ज करें',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Role & Location summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FBF8),
                      border: Border.all(
                        color: const Color(0xFFD6E7DF),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F1E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            roleIcon,
                            size: 26,
                            color: const Color(0xFF147A65),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRecycler
                                    ? l10n.recyclerAccountBadge
                                    : l10n.collectorAccountBadge,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF191919),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.state} • ${widget.city}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF147A65),
                          size: 22,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name field
                  _buildFieldLabel(l10n.fullName),
                  const SizedBox(height: 8),
                  _buildInputContainer(
                    icon: Icons.person_outline_rounded,
                    child: TextField(
                      key: const Key('register_name_field'),
                      controller: _nameController,
                      enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.fullNameHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF858585),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Phone number field
                  _buildFieldLabel(l10n.mobileLabel),
                  const SizedBox(height: 8),
                  _buildInputContainer(
                    icon: Icons.phone_android_outlined,
                    child: TextField(
                      key: const Key('register_phone_field'),
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !isLoading,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.mobileHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF858585),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password field
                  _buildFieldLabel(l10n.passwordLabel),
                  const SizedBox(height: 8),
                  _buildInputContainer(
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
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
                    child: TextField(
                      key: const Key('register_password_field'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.passwordMinHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF858585),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Pincode field (optional)
                  _buildFieldLabel(l10n.pincodeOptional),
                  const SizedBox(height: 8),
                  _buildInputContainer(
                    icon: Icons.pin_drop_outlined,
                    child: TextField(
                      key: const Key('register_pincode_field'),
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !isLoading,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.pincodeHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF858585),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Register submit button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      key: const Key('register_submit_button'),
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF147A65),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                                const Icon(Icons.check_rounded, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.registerAction,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link back to login
                  Center(
                    child: TextButton(
                      key: const Key('register_login_link'),
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                      child: Text(
                        l10n.alreadyHaveAccount,
                        style: const TextStyle(
                          color: Color(0xFF147A65),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF202020),
      ),
    );
  }

  Widget _buildInputContainer({
    required IconData icon,
    required Widget child,
    Widget? suffix,
  }) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF087F68),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(child: child),
          ?suffix,
        ],
      ),
    );
  }
}
