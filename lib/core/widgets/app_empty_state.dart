import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

/// Standard empty state container matching prototype `EmptyState.tsx`.
/// Features a gentle saffron icon circle, bold heading, helpful guidance text,
/// and an optional call-to-action button.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actionText,
    this.onAction,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMedium, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular icon badge
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.saffron50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  icon ??
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: AppColors.saffronPrimary,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.dark900,
              height: 1.25,
            ),
          ),

          // Description
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.dark500,
                height: 1.35,
              ),
            ),
          ],

          // Optional Action Button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 20),
            AppButton(
              text: actionText!,
              onPressed: onAction,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.md,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
