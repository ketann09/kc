import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/read_cache_storage.dart';
import '../../../../core/widgets/language_audio_sheet.dart';
import '../../../../core/widgets/offline_stale_banner.dart';
import '../../../../core/widgets/speaker_button.dart';
import '../../../../data/models/lot_model.dart';
import '../../../../domain/entities/lot_entity.dart';
import '../../../../domain/usecases/collector/get_lot_details_usecase.dart';
import '../../../../domain/usecases/transactions/get_collector_transactions_usecase.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';
import '../../collector_dependency_container.dart';

class CollectorLotDetailsScreen extends StatefulWidget {
  final String lotId;
  final LotEntity? initialLot;
  final GetLotDetailsUseCase? getLotDetailsUseCase;
  final GetCollectorTransactionsUseCase? getCollectorTransactionsUseCase;

  const CollectorLotDetailsScreen({
    super.key,
    required this.lotId,
    this.initialLot,
    this.getLotDetailsUseCase,
    this.getCollectorTransactionsUseCase,
  });

  @override
  State<CollectorLotDetailsScreen> createState() =>
      _CollectorLotDetailsScreenState();
}

class _CollectorLotDetailsScreenState extends State<CollectorLotDetailsScreen> {
  late final GetLotDetailsUseCase _getLotDetailsUseCase;
  late final GetCollectorTransactionsUseCase _getCollectorTransactionsUseCase;

  LotEntity? _lot;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCheckingTransaction = false;
  bool _isOffline = false;
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();
    if (widget.getLotDetailsUseCase != null &&
        widget.getCollectorTransactionsUseCase != null) {
      _getLotDetailsUseCase = widget.getLotDetailsUseCase!;
      _getCollectorTransactionsUseCase =
          widget.getCollectorTransactionsUseCase!;
    } else {
      final container = CollectorDependencyContainer.fromApiClient(ApiClient());
      _getLotDetailsUseCase = container.getLotDetailsUseCase;
      _getCollectorTransactionsUseCase =
          container.getCollectorTransactionsUseCase!;
    }

    if (widget.initialLot != null) {
      _lot = widget.initialLot;
      _isLoading = false;
    } else {
      _fetchLot();
    }
  }

  Future<void> _fetchLot() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    ReadCacheStorage? readCache;
    try {
      readCache = context.read<ReadCacheStorage>();
    } catch (_) {}

    try {
      final lot = await _getLotDetailsUseCase(widget.lotId);
      if (mounted) {
        setState(() {
          _lot = lot;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      final cached = await (readCache ?? SharedPreferencesReadCacheStorage()).get<LotEntity>(
        key: 'lot_detail_${widget.lotId}',
        fromJson: (json) => LotModel.fromJson(json),
      );
      if (mounted) {
        if (cached != null) {
          setState(() {
            _lot = cached.data;
            _isLoading = false;
            _isOffline = true;
            _cachedAt = cached.cachedAt;
          });
        } else {
          setState(() {
            _errorMessage = 'लॉट विवरण लोड नहीं हो सका: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleViewTransaction(LotEntity lot) async {
    setState(() {
      _isCheckingTransaction = true;
    });

    try {
      final transactions = await _getCollectorTransactionsUseCase(
        page: 1,
        limit: 50,
      );

      final matching = transactions.where((t) => t.lotId == lot.id);

      if (!mounted) return;
      setState(() {
        _isCheckingTransaction = false;
      });

      if (matching.isNotEmpty) {
        final txn = matching.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsScreen(
              transactionId: txn.id,
              initialTransaction: txn,
              isRecycler: false,
            ),
          ),
        );
      } else {
        _showNoTransactionDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingTransaction = false;
      });
      _showNoTransactionDialog();
    }
  }

  void _showNoTransactionDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE65100),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.isMarathi
                    ? 'व्यवहाराची स्थिती'
                    : 'लेन-देन की स्थिति',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          context.isMarathi
              ? 'या लॉटसाठी अद्याप व्यवहार तयार केला गेला नाही. रीसायकलरने नोंद केल्यावर हा व्यवहार दिसेल.'
              : 'इस लॉट के लिए रीसाइक्लर द्वारा अभी लेन-देन नहीं बनाया गया है। जैसे ही रीसाइक्लर लेन-देन दर्ज करेगा, यह आपकी लेन-देन सूची में दिखेगा।',
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.confirm),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.pushNamed(context, '/collector-transactions');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF147A65),
              foregroundColor: Colors.white,
            ),
            child: Text(
              context.isMarathi ? 'सर्व व्यवहार पहा' : 'सभी लेन-देन देखें',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          l10n.lotDetails,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () => LanguageAudioSheet.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language,
                      size: 15, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text(
                    context.currentLanguage.nativeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_lot != null)
            SpeakerButton(
              textToSpeak:
                  '${_isOffline ? "${l10n.offlineStaleNotice}। " : ""}${l10n.lotDetails}. ${_lot!.materialName ?? _lot!.description ?? ""}. ${l10n.weight}: ${_lot!.estimatedWeight} kg. ${l10n.estimatedPrice}: ₹${_lot!.estimatedPrice.toStringAsFixed(0)}.',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF147A65),
                  strokeWidth: 3,
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchLot,
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : _lot == null
                    ? const Center(child: Text('लॉट नहीं मिला'))
                    : _buildLotDetails(_lot!),
      ),
    );
  }

  Widget _buildLotDetails(LotEntity lot) {
    final l10n = context.l10n;
    final isCompleted = lot.status == LotStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isOffline) ...[
            OfflineStaleBanner(
              cachedAt: _cachedAt,
              onRefresh: _fetchLot,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'लॉट #${lot.id.length > 8 ? lot.id.substring(lot.id.length - 8) : lot.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(lot.status),
                  ],
                ),
                const Divider(height: 20),
                if (lot.materialName != null &&
                    lot.materialName!.isNotEmpty) ...[
                  _row(l10n.scrapType, lot.materialName!),
                  const SizedBox(height: 8),
                ] else if (lot.description != null &&
                    lot.description!.isNotEmpty) ...[
                  _row('विवरण', lot.description!),
                  const SizedBox(height: 8),
                ],
                _row(
                  context.isMarathi ? 'अंदाजे वजन' : 'अनुमानित वजन',
                  '${lot.estimatedWeight} kg',
                ),
                if (lot.actualWeight != null) ...[
                  const SizedBox(height: 8),
                  _row(
                    context.isMarathi ? 'प्रत्यक्ष वजन' : 'वास्तविक वजन',
                    '${lot.actualWeight} kg',
                  ),
                ],
                const SizedBox(height: 8),
                _row(
                  l10n.estimatedPrice,
                  '₹${lot.estimatedPrice.toStringAsFixed(0)}',
                ),
                if (lot.finalPrice != null) ...[
                  const SizedBox(height: 8),
                  _row(
                    context.isMarathi ? 'अंतिम किंमत' : 'अंतिम मूल्य',
                    '₹${lot.finalPrice!.toStringAsFixed(0)}',
                    isBold: true,
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1B5E20),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.isMarathi
                              ? 'हा लॉट यशस्वीरित्या पूर्ण झाला आहे'
                              : 'यह लॉट सफलतापूर्वक पूरा हो चुका है',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.isMarathi
                        ? 'या लॉटचा व्यवहार, देयक स्थिती आणि हस्तांतरण पाहण्यासाठी खालील बटण दाबा.'
                        : 'इस लॉट का लेन-देन, भुगतान स्थिति एवं हैंडओवर विवरण देखने के लिए नीचे दिए बटन पर टैप करें।',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isCheckingTransaction
                          ? null
                          : () => _handleViewTransaction(lot),
                      icon: _isCheckingTransaction
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.receipt_long),
                      label: Text(
                        l10n.viewTransaction,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(LotStatus status) {
    final l10n = context.l10n;
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case LotStatus.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF1B5E20);
        label = l10n.statusCompletedDetailed;
        break;
      case LotStatus.accepted:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = l10n.statusAccepted;
        break;
      case LotStatus.picked:
        bg = const Color(0xFFEDE7F6);
        fg = const Color(0xFF512DA8);
        label = l10n.statusPicked;
        break;
      case LotStatus.delivered:
        bg = const Color(0xFFF3F5F5);
        fg = const Color(0xFF00695C);
        label = l10n.statusDelivered;
        break;
      case LotStatus.cancelled:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = l10n.statusCancelled;
        break;
      case LotStatus.pending:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = l10n.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
