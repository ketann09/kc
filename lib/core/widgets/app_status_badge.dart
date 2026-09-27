import 'package:flutter/material.dart';

import '../../domain/entities/lot_entity.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

/// Status badge variant categories matching prototype `Badge.tsx`.
enum AppBadgeVariant {
  pending,
  accepted,
  picked,
  delivered,
  completed,
  cancelled,
  verified,
  bestMatch,
  saffron,
  green,
  blue,
  amber,
  red,
  gray,
}

/// A compact, low-literacy friendly status pill badge.
/// Follows the core rule: **Icon + Background Color + High-Contrast Text**
/// are always combined to ensure visual comprehension for all users.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;
  final bool isSmall;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.gray,
    this.isSmall = false,
  });

  /// Factory that automatically maps a [LotStatus] to its vernacular label,
  /// matching status color, and descriptive icon.
  factory AppStatusBadge.forLotStatus(BuildContext context, LotStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case LotStatus.pending:
        return AppStatusBadge(
          label: l10n.statusPending,
          icon: Icons.schedule_rounded,
          variant: AppBadgeVariant.pending,
        );
      case LotStatus.accepted:
        return AppStatusBadge(
          label: l10n.statusAccepted,
          icon: Icons.thumb_up_alt_outlined,
          variant: AppBadgeVariant.accepted,
        );
      case LotStatus.picked:
        return AppStatusBadge(
          label: l10n.statusPicked,
          icon: Icons.local_shipping_outlined,
          variant: AppBadgeVariant.picked,
        );
      case LotStatus.delivered:
        return AppStatusBadge(
          label: l10n.statusDelivered,
          icon: Icons.inventory_2_outlined,
          variant: AppBadgeVariant.delivered,
        );
      case LotStatus.completed:
        return AppStatusBadge(
          label: l10n.statusCompleted,
          icon: Icons.check_circle_outline_rounded,
          variant: AppBadgeVariant.completed,
        );
      case LotStatus.cancelled:
        return AppStatusBadge(
          label: l10n.statusCancelled,
          icon: Icons.cancel_outlined,
          variant: AppBadgeVariant.cancelled,
        );
    }
  }

  /// Factory for a "Verified Buyer / Recycler" trust badge.
  factory AppStatusBadge.verified({
    Key? key,
    required String label,
    bool isSmall = false,
  }) {
    return AppStatusBadge(
      key: key,
      label: label,
      icon: Icons.verified_user_rounded,
      variant: AppBadgeVariant.verified,
      isSmall: isSmall,
    );
  }

  /// Factory for a "Best Match" matchmaking badge.
  factory AppStatusBadge.bestMatch({
    Key? key,
    required String label,
    bool isSmall = false,
  }) {
    return AppStatusBadge(
      key: key,
      label: label,
      icon: Icons.workspace_premium_rounded,
      variant: AppBadgeVariant.bestMatch,
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData? defaultIcon;

    switch (variant) {
      case AppBadgeVariant.pending:
      case AppBadgeVariant.amber:
        bg = AppColors.amber50;
        fg = AppColors.amber700;
        border = AppColors.amber200;
        defaultIcon = Icons.schedule_rounded;
        break;
      case AppBadgeVariant.accepted:
      case AppBadgeVariant.blue:
        bg = AppColors.blue50;
        fg = AppColors.blue700;
        border = AppColors.blue200;
        defaultIcon = Icons.thumb_up_alt_outlined;
        break;
      case AppBadgeVariant.picked:
        bg = AppColors.emerald50;
        fg = AppColors.emerald700;
        border = AppColors.emerald200;
        defaultIcon = Icons.local_shipping_outlined;
        break;
      case AppBadgeVariant.delivered:
        bg = AppColors.purple50;
        fg = AppColors.purple700;
        border = AppColors.purple200;
        defaultIcon = Icons.inventory_2_outlined;
        break;
      case AppBadgeVariant.completed:
      case AppBadgeVariant.green:
      case AppBadgeVariant.verified:
        bg = AppColors.green50;
        fg = AppColors.green700;
        border = AppColors.green100;
        defaultIcon = Icons.check_circle_outline_rounded;
        break;
      case AppBadgeVariant.cancelled:
      case AppBadgeVariant.red:
        bg = AppColors.red50;
        fg = AppColors.redPrimary;
        border = AppColors.red200;
        defaultIcon = Icons.cancel_outlined;
        break;
      case AppBadgeVariant.bestMatch:
      case AppBadgeVariant.saffron:
        bg = AppColors.saffron50;
        fg = AppColors.saffronDark;
        border = AppColors.saffron200;
        defaultIcon = Icons.workspace_premium_rounded;
        break;
      case AppBadgeVariant.gray:
        bg = AppColors.border;
        fg = AppColors.dark700;
        border = AppColors.borderMedium;
        defaultIcon = null;
        break;
    }

    final effectiveIcon = icon ?? defaultIcon;
    final iconSize = isSmall ? 12.0 : 14.0;
    final fontSize = isSmall ? 10.5 : 12.0;
    final verticalPadding = isSmall ? 2.5 : 4.5;
    final horizontalPadding = isSmall ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (effectiveIcon != null) ...[
            Icon(effectiveIcon, size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
