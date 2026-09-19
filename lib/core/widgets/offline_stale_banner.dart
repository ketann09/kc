import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'speaker_button.dart';

/// A lightweight, reusable banner that indicates the displayed data is offline/stale.
/// Never presents cached data as freshly synced backend data.
class OfflineStaleBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final EdgeInsetsGeometry? margin;

  const OfflineStaleBanner({
    super.key,
    this.cachedAt,
    this.onRefresh,
    this.isRefreshing = false,
    this.margin,
  });

  String _formatTime(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeStr = cachedAt != null ? _formatTime(context, cachedAt!) : null;

    final spokenText = timeStr != null
        ? '${l10n.offlineStaleNotice}। ${l10n.lastUpdatedPrefix}: $timeStr'
        : '${l10n.offlineStaleNotice}।';

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Amber 50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFCD34D), // Amber 300
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFB45309), // Amber 700
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.offlineStaleNotice,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF78350F), // Amber 900
                  ),
                ),
                if (timeStr != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.lastUpdatedPrefix}: $timeStr',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF92400E), // Amber 800
                    ),
                  ),
                ],
              ],
            ),
          ),
          SpeakerButton(
            textToSpeak: spokenText,
            color: const Color(0xFFB45309),
            size: 20,
          ),
          if (onRefresh != null) ...[
            const SizedBox(width: 4),
            isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFB45309),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    iconSize: 20,
                    color: const Color(0xFFB45309),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: l10n.retry,
                    onPressed: onRefresh,
                  ),
          ],
        ],
      ),
    );
  }
}
