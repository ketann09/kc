import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Card style variants matching prototype `Card.tsx`.
enum AppCardVariant {
  /// Default surface: White background, subtle border, gentle shadow.
  defaultCard,

  /// Warm surface: Soft saffron-50 background, saffron-200 border.
  warm,

  /// Flat surface: White background, medium border, no shadow.
  flat,

  /// Highlight surface: Subtle saffron border, soft warm gradient.
  highlight,

  /// Dashed action surface: Saffron dashed border, white/saffron-50 background.
  dashed,
}

/// A standard card container for Kabadiwala Connect.
/// Follows the 16dp standard corner radius, warm surfaces, and touch-friendly design.
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.defaultCard,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16.0,
    this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
  });

  /// Factory constructor for a warm highlighted card.
  factory AppCard.warm({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    double borderRadius = 16.0,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      variant: AppCardVariant.warm,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Factory constructor for an action card with dashed border.
  factory AppCard.dashed({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    double borderRadius = 16.0,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      variant: AppCardVariant.dashed,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Color resolvedBg;
    BoxBorder? resolvedBorder;
    List<BoxShadow>? resolvedShadow;

    switch (variant) {
      case AppCardVariant.defaultCard:
        resolvedBg = backgroundColor ?? AppColors.white;
        resolvedBorder = border ?? Border.all(color: AppColors.border, width: 1.0);
        resolvedShadow = const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ];
        break;
      case AppCardVariant.warm:
        resolvedBg = backgroundColor ?? AppColors.saffron50;
        resolvedBorder = border ?? Border.all(color: AppColors.saffron200, width: 1.0);
        resolvedShadow = const [
          BoxShadow(
            color: Color(0x08FF6B00),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ];
        break;
      case AppCardVariant.flat:
        resolvedBg = backgroundColor ?? AppColors.white;
        resolvedBorder = border ?? Border.all(color: AppColors.borderMedium, width: 1.0);
        resolvedShadow = null;
        break;
      case AppCardVariant.highlight:
        resolvedBg = backgroundColor ?? AppColors.saffron50.withValues(alpha: 0.5);
        resolvedBorder = border ?? Border.all(color: AppColors.saffron200, width: 1.5);
        resolvedShadow = const [
          BoxShadow(
            color: Color(0x12FF6B00),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ];
        break;
      case AppCardVariant.dashed:
        resolvedBg = backgroundColor ?? AppColors.white;
        resolvedBorder = null; // Painted by CustomPainter below
        resolvedShadow = const [
          BoxShadow(
            color: Color(0x08FF6B00),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ];
        break;
    }

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      child: child,
    );

    if (variant == AppCardVariant.dashed) {
      content = CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.saffron300,
          strokeWidth: 2.0,
          gap: 5.0,
          dashLength: 7.0,
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    final cardContainer = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: radius,
        border: resolvedBorder,
        boxShadow: resolvedShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  splashColor: AppColors.saffron100.withValues(alpha: 0.6),
                  highlightColor: AppColors.saffron50,
                  child: content,
                ),
              )
            : content,
      ),
    );

    return cardContainer;
  }
}

/// Custom painter for rounded dashed borders.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final extractPath = metric.extractPath(
          distance,
          next > metric.length ? metric.length : next,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
