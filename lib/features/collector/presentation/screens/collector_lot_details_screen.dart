import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
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
  LotEntity? _lot;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCheckingTransaction = false;

  late final GetLotDetailsUseCase _getLotDetailsUseCase;
  late final GetCollectorTransactionsUseCase _getCollectorTransactionsUseCase;

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

    try {
      final lot = await _getLotDetailsUseCase(widget.lotId);
      if (mounted) {
        setState(() {
          _lot = lot;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'लॉट विवरण लोड नहीं हो सका: ${e.toString()}';
          _isLoading = false;
        });
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
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE65100),
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'लेन-देन की स्थिति',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'इस लॉट के लिए रीसाइक्लर द्वारा अभी लेन-देन नहीं बनाया गया है। जैसे ही रीसाइक्लर लेन-देन दर्ज करेगा, यह आपकी लेन-देन सूची में दिखेगा।',
          style: TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('ठीक है'),
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
            child: const Text('सभी लेन-देन देखें'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'लॉट विवरण',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
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
                        child: const Text('पुनः प्रयास करें'),
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
    final isCompleted = lot.status == LotStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  _row('सामग्री', lot.materialName!),
                  const SizedBox(height: 8),
                ] else if (lot.description != null &&
                    lot.description!.isNotEmpty) ...[
                  _row('विवरण', lot.description!),
                  const SizedBox(height: 8),
                ],
                _row('अनुमानित वजन', '${lot.estimatedWeight} किग्रा'),
                if (lot.actualWeight != null) ...[
                  const SizedBox(height: 8),
                  _row('वास्तविक वजन', '${lot.actualWeight} किग्रा'),
                ],
                const SizedBox(height: 8),
                _row(
                  'अनुमानित मूल्य',
                  '₹${lot.estimatedPrice.toStringAsFixed(0)}',
                ),
                if (lot.finalPrice != null) ...[
                  const SizedBox(height: 8),
                  _row(
                    'अंतिम मूल्य',
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
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF1B5E20),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'यह लॉट सफलतापूर्वक पूरा हो चुका है',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'इस लॉट का लेन-देन, भुगतान स्थिति एवं हैंडओवर विवरण देखने के लिए नीचे दिए बटन पर टैप करें।',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
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
                      label: const Text(
                        'लेन-देन देखें',
                        style: TextStyle(
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
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case LotStatus.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF1B5E20);
        label = 'पूरा हुआ';
        break;
      case LotStatus.accepted:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = 'स्वीकृत';
        break;
      case LotStatus.picked:
        bg = const Color(0xFFEDE7F6);
        fg = const Color(0xFF512DA8);
        label = 'पिकअप';
        break;
      case LotStatus.delivered:
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF7B1FA2);
        label = 'डिलीवर';
        break;
      case LotStatus.cancelled:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = 'रद्द';
        break;
      case LotStatus.pending:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = 'लंबित';
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
