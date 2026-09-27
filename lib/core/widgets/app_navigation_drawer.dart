import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_event.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import 'change_password_sheet.dart';
import 'language_audio_sheet.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void _navigate(BuildContext context, String routeName) {
    Navigator.pop(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != routeName) {
      Navigator.pushNamed(context, routeName);
    }
  }

  void _confirmLogout(BuildContext context) {
    final l10n = context.l10n;
    final authBloc = context.read<AuthBloc>();
    final navigator = Navigator.of(context);

    // Close drawer
    navigator.pop();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        key: const Key('confirm_logout_dialog'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.redPrimary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              l10n.confirmLogoutTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark900,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.confirmLogoutMessage,
          style: const TextStyle(fontSize: 15, color: AppColors.dark700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.cancelAction,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.dark500,
              ),
            ),
          ),
          ElevatedButton(
            key: const Key('confirm_logout_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              authBloc.add(const AuthLogoutRequested());
              navigator.pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    UserEntity? user;
    try {
      final authState = context.watch<AuthBloc>().state;
      if (authState is Authenticated) {
        user = authState.user;
      }
    } catch (_) {}

    final isRecycler = user?.role == UserRole.recycler;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (isRecycler ? 'रीसाइक्लर पार्टनर' : 'कलेक्टर पार्टनर');
    final phoneNumber = user?.phoneNumber ?? '';
    final initialLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'K';

    return Drawer(
      backgroundColor: AppColors.pageBackground,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.saffron50,
                border: Border(
                  bottom: BorderSide(color: AppColors.saffron200, width: 1.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.saffronPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x18000000),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initialLetter,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (phoneNumber.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '+91 $phoneNumber',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dark500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isRecycler
                              ? AppColors.green50
                              : AppColors.saffron100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isRecycler
                                ? AppColors.greenPrimary.withValues(alpha: 0.3)
                                : AppColors.saffronPrimary
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isRecycler ? 'रीसाइक्लर' : 'कलेक्टर',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isRecycler
                                ? AppColors.green700
                                : AppColors.saffronDark,
                          ),
                        ),
                      ),
                      if (user?.address?.city != null &&
                          user!.address!.city!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderMedium),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.dark500,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                user.address!.city!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      l10n.navigationMenu,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Dashboard
                  _DrawerTile(
                    key: const Key('drawer_dashboard_item'),
                    icon: Icons.dashboard_rounded,
                    title: l10n.dashboardAction,
                    onTap: () => _navigate(
                      context,
                      isRecycler
                          ? '/recycler-dashboard'
                          : '/collector-dashboard',
                    ),
                  ),

                  // My Lots
                  _DrawerTile(
                    key: const Key('drawer_lots_item'),
                    icon: Icons.inventory_2_rounded,
                    title: l10n.myRecentLots,
                    onTap: () => _navigate(
                      context,
                      isRecycler ? '/recycler-dashboard' : '/collector-lots',
                    ),
                  ),

                  // Transactions
                  _DrawerTile(
                    key: const Key('drawer_transactions_item'),
                    icon: Icons.account_balance_wallet_rounded,
                    title: l10n.myEarningsAndTransactions,
                    onTap: () => _navigate(context, '/collector-transactions'),
                  ),

                  // New Lot (Only for Collector)
                  if (!isRecycler)
                    _DrawerTile(
                      key: const Key('drawer_new_lot_item'),
                      icon: Icons.add_circle_outline_rounded,
                      title: l10n.createNewLot,
                      iconColor: AppColors.saffronPrimary,
                      onTap: () => _navigate(context, '/new-lot'),
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: AppColors.borderMedium),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      l10n.accountSettings,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Change Language
                  _DrawerTile(
                    key: const Key('drawer_language_item'),
                    icon: Icons.translate_rounded,
                    title: 'भाषा / Language',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.saffron100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.currentLanguage.nativeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.saffronDark,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      LanguageAudioSheet.show(context);
                    },
                  ),

                  // Change Password
                  _DrawerTile(
                    key: const Key('drawer_change_password_item'),
                    icon: Icons.lock_reset_rounded,
                    title: l10n.changePassword,
                    onTap: () {
                      Navigator.pop(context);
                      ChangePasswordSheet.show(context);
                    },
                  ),

                  // Logout
                  _DrawerTile(
                    key: const Key('drawer_logout_item'),
                    icon: Icons.logout_rounded,
                    title: l10n.logout,
                    iconColor: AppColors.redPrimary,
                    textColor: AppColors.redPrimary,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.dark700,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.dark900,
        ),
      ),
      trailing: trailing,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }
}
