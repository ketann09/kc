import 'package:flutter/material.dart';

/// Centralized design tokens and color palette for Kabadiwala Connect.
/// Derived from the reference prototype (`Frontend.zip`) with saffron brand primary,
/// India green for success/verified, amber for pending/offline alerts, and warm surfaces.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Saffron / Brand Identity (Primary Palette)
  // ---------------------------------------------------------------------------
  static const Color saffronPrimary = Color(
    0xFFFF6B00,
  ); // Primary Saffron #FF6B00
  static const Color saffronDark = Color(0xFFE05E00); // Saffron-600 #E05E00
  static const Color saffron50 = Color(0xFFFFF8F2); // Warm Saffron-50 #FFF8F2
  static const Color saffron100 = Color(0xFFFFF4E8); // Saffron-100 #FFF4E8
  static const Color saffron200 = Color(0xFFFFE4CC); // Saffron-200 #FFE4CC
  static const Color saffron300 = Color(0xFFFFC499); // Saffron-300 #FFC499
  static const Color saffron400 = Color(0xFFFFA05C); // Saffron-400 #FFA05C
  static const Color saffron700 = Color(0xFFB84D00); // Saffron-700
  static const Color saffron800 = Color(0xFF8F3C00); // Saffron-800
  static const Color saffron900 = Color(0xFF662B00); // Saffron-900

  // ---------------------------------------------------------------------------
  // India Green (Success, Verified, Payouts, Completed)
  // ---------------------------------------------------------------------------
  static const Color greenPrimary = Color(0xFF16A34A); // #16A34A
  static const Color green50 = Color(0xFFF0FDF4); // #F0FDF4
  static const Color green100 = Color(0xFFDCFCE7); // #DCFCE7
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D); // #15803D

  // ---------------------------------------------------------------------------
  // Amber / Warning (Pending, Offline Warning, Action Required)
  // ---------------------------------------------------------------------------
  static const Color amberPrimary = Color(0xFFD97706); // #D97706
  static const Color amber50 = Color(0xFFFFFBEB); // #FFFBEB
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber700 = Color(0xFFB45309);

  // ---------------------------------------------------------------------------
  // Blue (Accepted, Info, Buyer Identity)
  // ---------------------------------------------------------------------------
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue700 = Color(0xFF1D4ED8);

  // ---------------------------------------------------------------------------
  // Emerald & Purple (Lifecycle transitions)
  // ---------------------------------------------------------------------------
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald700 = Color(0xFF047857);

  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple200 = Color(0xFFE9D5FF);
  static const Color purple700 = Color(0xFF7E22CE);

  // ---------------------------------------------------------------------------
  // Red (Errors, Rejected, Destructive Actions)
  // ---------------------------------------------------------------------------
  static const Color redPrimary = Color(0xFFDC2626); // #DC2626
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);

  // ---------------------------------------------------------------------------
  // Backgrounds & Surfaces
  // ---------------------------------------------------------------------------
  static const Color pageBackground = Color(
    0xFFFFFDFB,
  ); // Warm off-white #FFFDFB
  static const Color white = Color(0xFFFFFFFF); // Card white #FFFFFF
  static const Color cardWarm = Color(0xFFFFF8F2);

  // ---------------------------------------------------------------------------
  // Dark Neutrals & Typography
  // ---------------------------------------------------------------------------
  static const Color dark900 = Color(
    0xFF111827,
  ); // #111827 - Headings, hero figures
  static const Color dark800 = Color(0xFF1F2937); // #1F2937
  static const Color dark700 = Color(0xFF374151); // #374151 - Body text
  static const Color dark600 = Color(0xFF4B5563); // #4B5563
  static const Color dark500 = Color(
    0xFF6B7280,
  ); // #6B7280 - Subtitles, captions
  static const Color dark400 = Color(0xFF9CA3AF);

  // ---------------------------------------------------------------------------
  // Borders & Dividers
  // ---------------------------------------------------------------------------
  static const Color border = Color(0xFFF3F4F6); // Standard card border #F3F4F6
  static const Color borderMedium = Color(0xFFE5E7EB);
  static const Color borderWarm = Color(0xFFFFE4CC); // Saffron-200 border
}
