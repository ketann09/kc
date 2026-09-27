import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Button visual style variants matching prototype `Button.tsx`.
enum AppButtonVariant {
  /// Primary saffron button (#FF6B00) with white text and subtle shadow.
  primary,

  /// Secondary soft warm button (#FFF8F2) with saffron text and border.
  secondary,

  /// Outline button: white background with neutral border.
  outline,

  /// Success button: India Green (#16A34A) with white text.
  success,

  /// Destructive danger button (#DC2626) with white text.
  danger,

  /// Ghost button: transparent background with neutral text.
  ghost,
}

/// Button size categories.
enum AppButtonSize {
  /// Large: 56dp minimum height (standard for all primary mobile actions).
  lg,

  /// Medium: 48dp minimum height (standard for secondary actions).
  md,

  /// Small: 38dp height (for compact inline actions inside cards).
  sm,
}

/// Standardized touch-friendly button for Kabadiwala Connect.
/// Ensures minimum 56dp height for primary actions and 48dp for secondary actions,
/// with integrated loading state and left/right icon support.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final String? loadingText;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final double? width;
  final bool isFullWidth;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.isLoading = false,
    this.loadingText,
    this.leftIcon,
    this.rightIcon,
    this.width,
    this.isFullWidth = false,
    this.borderRadius = 14.0,
  });

  /// Factory for a full-width primary 56dp action button.
  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    String? loadingText,
    Widget? leftIcon,
    Widget? rightIcon,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: AppButtonSize.lg,
      isLoading: isLoading,
      loadingText: loadingText,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      isFullWidth: isFullWidth,
    );
  }

  /// Factory for a secondary warm action button.
  factory AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
    AppButtonSize size = AppButtonSize.md,
    bool isFullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      isFullWidth: isFullWidth,
    );
  }

  /// Factory for a verified success button.
  factory AppButton.success({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
    bool isFullWidth = true,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.success,
      size: AppButtonSize.lg,
      isLoading: isLoading,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      isFullWidth: isFullWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = switch (size) {
      AppButtonSize.lg => 56.0,
      AppButtonSize.md => 48.0,
      AppButtonSize.sm => 38.0,
    };

    final horizontalPadding = switch (size) {
      AppButtonSize.lg => 20.0,
      AppButtonSize.md => 16.0,
      AppButtonSize.sm => 12.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.lg => 16.0,
      AppButtonSize.md => 14.0,
      AppButtonSize.sm => 12.5,
    };

    Color bgColor;
    Color fgColor;
    BorderSide borderSide;
    List<BoxShadow>? shadows;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.saffronPrimary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        shadows = const [
          BoxShadow(
            color: Color(0x28FF6B00),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.saffron50;
        fgColor = AppColors.saffronDark;
        borderSide = const BorderSide(color: AppColors.saffron200, width: 1.2);
        shadows = null;
        break;
      case AppButtonVariant.outline:
        bgColor = AppColors.white;
        fgColor = AppColors.dark700;
        borderSide = const BorderSide(color: AppColors.borderMedium, width: 1.2);
        shadows = null;
        break;
      case AppButtonVariant.success:
        bgColor = AppColors.greenPrimary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        shadows = const [
          BoxShadow(
            color: Color(0x2816A34A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ];
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.redPrimary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        shadows = const [
          BoxShadow(
            color: Color(0x28DC2626),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ];
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.dark700;
        borderSide = BorderSide.none;
        shadows = null;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;
    if (!isEnabled) {
      if (variant == AppButtonVariant.primary ||
          variant == AppButtonVariant.success ||
          variant == AppButtonVariant.danger) {
        bgColor = bgColor.withValues(alpha: 0.55);
      }
      shadows = null;
    }

    Widget content;
    if (isLoading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          if (loadingText != null) ...[
            const SizedBox(width: 10),
            Text(
              loadingText!,
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leftIcon != null) ...[
            leftIcon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (rightIcon != null) ...[
            const SizedBox(width: 8),
            rightIcon!,
          ],
        ],
      );
    }

    final radius = BorderRadius.circular(borderRadius);

    return Container(
      width: isFullWidth ? double.infinity : width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: borderSide.style != BorderStyle.none
            ? Border.fromBorderSide(borderSide)
            : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
