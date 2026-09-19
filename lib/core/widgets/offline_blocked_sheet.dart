import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/app_localizations.dart';
import '../localization/translations/app_translations.dart';
import '../services/connectivity_service.dart';
import 'speaker_button.dart';

/// The specific consequential mutation that was blocked due to lack of connectivity.
enum OfflineBlockedAction {
  createLot,
  confirmOffer,
  acceptLot,
  markPicked,
  markDelivered,
  completeLot,
  createTransaction,
  updateHandover,
  processPayment,
  register,
  generic,
}

/// A bottom sheet designed for low-literacy vernacular users that clearly explains
/// why a mutation cannot proceed while offline, provides audible readout via [SpeakerButton],
/// and allows testing whether connectivity has been restored without losing screen inputs.
class OfflineBlockedSheet extends StatefulWidget {
  final OfflineBlockedAction action;
  final VoidCallback? onRetry;
  final ConnectivityService? connectivityService;

  const OfflineBlockedSheet({
    super.key,
    this.action = OfflineBlockedAction.generic,
    this.onRetry,
    this.connectivityService,
  });

  /// Displays the modal sheet.
  static Future<void> show(
    BuildContext context, {
    OfflineBlockedAction action = OfflineBlockedAction.generic,
    VoidCallback? onRetry,
    ConnectivityService? connectivityService,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) => OfflineBlockedSheet(
        action: action,
        onRetry: onRetry,
        connectivityService: connectivityService,
      ),
    );
  }

  @override
  State<OfflineBlockedSheet> createState() => _OfflineBlockedSheetState();
}

class _OfflineBlockedSheetState extends State<OfflineBlockedSheet> {
  bool _isChecking = false;
  String? _statusMessage;
  bool? _isSuccess;

  String _getActionMessage(AppTranslations l10n) {
    switch (widget.action) {
      case OfflineBlockedAction.createLot:
        return l10n.offlineCreateLotBlocked;
      case OfflineBlockedAction.confirmOffer:
        return l10n.offlineConfirmOfferBlocked;
      case OfflineBlockedAction.acceptLot:
        return l10n.offlineAcceptLotBlocked;
      case OfflineBlockedAction.markPicked:
        return l10n.offlineMarkPickedBlocked;
      case OfflineBlockedAction.markDelivered:
        return l10n.offlineMarkDeliveredBlocked;
      case OfflineBlockedAction.completeLot:
        return l10n.offlineCompleteLotBlocked;
      case OfflineBlockedAction.createTransaction:
        return l10n.offlineCreateTransactionBlocked;
      case OfflineBlockedAction.updateHandover:
        return l10n.offlineUpdateHandoverBlocked;
      case OfflineBlockedAction.processPayment:
        return l10n.offlineUpdatePaymentBlocked;
      case OfflineBlockedAction.register:
        return l10n.offlineRegisterBlocked;
      case OfflineBlockedAction.generic:
        return l10n.offlineNoticeSubtitle;
    }
  }

  Future<void> _handleCheckConnection(AppTranslations l10n) async {
    setState(() {
      _isChecking = true;
      _statusMessage = l10n.connectionChecking;
      _isSuccess = null;
    });

    ConnectivityService? service = widget.connectivityService;
    if (service == null) {
      try {
        service = context.read<ConnectivityService>();
      } catch (_) {
        service = null;
      }
    }

    final isOnline = await (service?.checkConnection() ?? Future.value(false));

    if (!mounted) return;

    if (isOnline) {
      setState(() {
        _isChecking = false;
        _isSuccess = true;
        _statusMessage = l10n.connectionRestored;
      });

      // Brief pause to show green feedback before closing and retrying
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onRetry?.call();
    } else {
      setState(() {
        _isChecking = false;
        _isSuccess = false;
        _statusMessage = l10n.connectionStillOffline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actionMessage = _getActionMessage(l10n);
    final textToSpeak =
        '${l10n.offlineNoticeTitle}. $actionMessage. ${l10n.offlineActionHelp}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Prominent visual offline icon
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.shade300, width: 2),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title with speaker button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    l10n.offlineNoticeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SpeakerButton(
                  textToSpeak: textToSpeak,
                  size: 26,
                  color: Colors.amber.shade900,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action-specific vernacular explanation card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionMessage,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.offlineActionHelp,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status message during or after connection probe
            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isSuccess == true
                      ? Colors.green.shade50
                      : (_isSuccess == false
                          ? Colors.red.shade50
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isSuccess == true
                        ? Colors.green.shade300
                        : (_isSuccess == false
                            ? Colors.red.shade300
                            : Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isChecking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    else if (_isSuccess == true)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      )
                    else if (_isSuccess == false)
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isSuccess == true
                              ? Colors.green.shade800
                              : (_isSuccess == false
                                  ? Colors.red.shade800
                                  : Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Primary Check Connection action (min 56dp height)
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isChecking
                    ? null
                    : () => _handleCheckConnection(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: Text(
                  l10n.checkConnectionAction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Dismiss action (min 48dp height)
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.back,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
