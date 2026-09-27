import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Icon avatar background accent categories for stat cards.
enum AppStatAccent { saffron, green, amber, blue }

/// A compact dashboard statistics card designed for mobile 2x2 grids.
/// Matches prototype stat cards with high-contrast numerical figures,
/// localized metric labels, and soft-tinted icon avatars.
class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final AppStatAccent accent;
  final VoidCallback? onTap;
  final Color? valueColor;
  final String? subtitle;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppStatAccent.saffron,
    this.onTap,
    this.valueColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    Color iconColor;
    Color defaultValColor;

    switch (accent) {
      case AppStatAccent.saffron:
        iconBg = AppColors.saffron50;
        iconColor = AppColors.saffronPrimary;
        defaultValColor = AppColors.dark900;
        break;
      case AppStatAccent.green:
        iconBg = AppColors.green50;
        iconColor = AppColors.greenPrimary;
        defaultValColor = AppColors.green700;
        break;
      case AppStatAccent.amber:
        iconBg = AppColors.amber50;
        iconColor = AppColors.amberPrimary;
        defaultValColor = AppColors.amberPrimary;
        break;
      case AppStatAccent.blue:
        iconBg = AppColors.blue50;
        iconColor = AppColors.bluePrimary;
        defaultValColor = AppColors.blue700;
        break;
    }

    final effectiveValueColor = valueColor ?? defaultValColor;

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Label + Big Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark500,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: effectiveValueColor,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.dark400,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Icon avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ],
      ),
    );

    final radius = BorderRadius.circular(16);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  splashColor: iconBg,
                  child: cardContent,
                ),
              )
            : cardContent,
      ),
    );
  }
}
