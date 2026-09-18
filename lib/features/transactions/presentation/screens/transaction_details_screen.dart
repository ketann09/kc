import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../domain/entities/lot_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../recycler/recycler_dependency_container.dart';
import '../bloc/transaction_details_bloc.dart';
import '../bloc/transaction_details_event.dart';
import '../bloc/transaction_details_state.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String? transactionId;
  final TransactionEntity? initialTransaction;
  final String? lotId;
  final LotEntity? lot;
  final bool isRecycler;
  final TransactionDetailsBloc? bloc;

  const TransactionDetailsScreen({
    super.key,
    this.transactionId,
    this.initialTransaction,
    this.lotId,
    this.lot,
    this.isRecycler = true,
    this.bloc,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late final TransactionDetailsBloc _bloc;
  bool _isLocalBloc = false;

  // Controllers for Create Transaction flow (when creating directly from screen)
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Controllers for Handover Dialog
  final TextEditingController _receivedByController = TextEditingController();
  final TextEditingController _verifiedByController = TextEditingController();

  // Controllers for Payment Dialog
  PaymentStatus _selectedPaymentStatus = PaymentStatus.completed;
  final TextEditingController _paymentRefController = TextEditingController();
  final TextEditingController _receiptUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
    } else {
      _isLocalBloc = true;
      final container = RecyclerDependencyContainer.fromApiClient(ApiClient());
      _bloc = container.createTransactionDetailsBloc();
    }

    if (widget.initialTransaction != null) {
      // Seed with initial transaction
      // ignore: invalid_use_of_visible_for_testing_member
      _bloc.emit(TransactionDetailsLoaded(widget.initialTransaction!));
    } else if (widget.transactionId != null &&
        widget.transactionId!.isNotEmpty) {
      _bloc.add(FetchTransactionDetailsEvent(widget.transactionId!));
    } else if (widget.lot != null) {
      final defaultAmount =
          widget.lot!.finalPrice ?? widget.lot!.estimatedPrice;
      if (defaultAmount > 0) {
        _amountController.text = defaultAmount.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _bloc.close();
    }
    _amountController.dispose();
    _notesController.dispose();
    _receivedByController.dispose();
    _verifiedByController.dispose();
    _paymentRefController.dispose();
    _receiptUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text(
            'लेन-देन विवरण',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocConsumer<TransactionDetailsBloc, TransactionDetailsState>(
            listener: (context, state) {
              if (state is TransactionDetailsLoaded) {
                if (state.actionSuccessMessage != null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionSuccessMessage!),
                      backgroundColor: const Color(0xFF1B5E20),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _bloc.add(const ResetTransactionActionEvent());
                } else if (state.actionErrorMessage != null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionErrorMessage!),
                      backgroundColor: const Color(0xFFD32F2F),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _bloc.add(const ResetTransactionActionEvent());
                }
              }
            },
            builder: (context, state) {
              if (state is TransactionDetailsLoading) {
                return _buildLoadingState();
              } else if (state is TransactionDetailsFailure) {
                return _buildFailureState(context, state.message);
              } else if (state is TransactionDetailsLoaded) {
                return _buildLoadedState(context, state);
              } else if (widget.lotId != null || widget.lot != null) {
                // Show form to create transaction
                return _buildCreateTransactionState(context);
              }
              return const Center(child: Text('कोई लेन-देन नहीं चुना गया'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF147A65), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'लेन-देन लोड हो रहा है...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191919),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'त्रुटि हुई',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            if (widget.transactionId != null)
              ElevatedButton.icon(
                onPressed: () => _bloc.add(
                  FetchTransactionDetailsEvent(widget.transactionId!),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('पुनः प्रयास करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF147A65),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTransactionState(BuildContext context) {
    final lot = widget.lot;
    final lotId = widget.lotId ?? lot?.id ?? '';
    final estWeight = lot?.estimatedWeight ?? 0.0;
    final actWeight = lot?.actualWeight ?? estWeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF147A65),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'लॉट #$lotId के लिए लेन-देन बनाएं',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _summaryRow(
                  'अनुमानित वजन',
                  '${estWeight.toStringAsFixed(1)} किग्रा',
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  'वास्तविक वजन',
                  '${actWeight.toStringAsFixed(1)} किग्रा',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'लेन-देन राशि (₹)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'उदा. 2500',
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'भुगतान विधि चुनें',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentMethod.values.map((method) {
              final isSelected = _selectedPaymentMethod == method;
              return ChoiceChip(
                label: Text(method.hindiLabel),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  }
                },
                selectedColor: const Color(0xFFE8F5E9),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF374151),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'टिप्पणी (वैकल्पिक)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'अतिरिक्त विवरण या संदर्भ...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'प्लेटफ़ॉर्म शुल्क 5% स्वतः लागू होगा और शुद्ध राशि की गणना होगी।',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(_amountController.text.trim());
                if (amt == null || amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('कृपया मान्य राशि दर्ज करें'),
                      backgroundColor: Color(0xFFD32F2F),
                    ),
                  );
                  return;
                }

                _bloc.add(
                  CreateTransactionEvent(
                    lotId: lotId,
                    paymentMethod: _selectedPaymentMethod.value,
                    amount: amt,
                    actualWeight: actWeight,
                    estimatedWeight: estWeight,
                    notes: _notesController.text.trim().isNotEmpty
                        ? _notesController.text.trim()
                        : null,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF147A65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'लेन-देन बनाएं',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    TransactionDetailsLoaded state,
  ) {
    final txn = state.transaction;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransactionHeaderCard(txn),
          const SizedBox(height: 16),
          _buildPartiesCard(txn),
          const SizedBox(height: 16),
          _buildFinancialCard(txn),
          const SizedBox(height: 16),
          _buildHandoverCard(context, state),
          const SizedBox(height: 16),
          _buildPaymentCard(context, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionHeaderCard(TransactionEntity txn) {
    Color statusColor;
    Color statusBgColor;
    switch (txn.status) {
      case TransactionStatus.completed:
        statusColor = const Color(0xFF1B5E20);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case TransactionStatus.inProgress:
        statusColor = const Color(0xFFE65100);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case TransactionStatus.failed:
      case TransactionStatus.refunded:
        statusColor = const Color(0xFFC62828);
        statusBgColor = const Color(0xFFFFEBEE);
        break;
      case TransactionStatus.initiated:
        statusColor = const Color(0xFF1565C0);
        statusBgColor = const Color(0xFFE3F2FD);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                'आईडी: #${txn.id.length > 8 ? txn.id.substring(txn.id.length - 8) : txn.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  txn.status.hindiLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (txn.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'दिनांक: ${txn.createdAt!.day}/${txn.createdAt!.month}/${txn.createdAt!.year}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          if (txn.lotId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'लॉट संदर्भ: #${txn.lotId}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartiesCard(TransactionEntity txn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'पक्षकार विवरण',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: Color(0xFF147A65),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'कलेक्टर (विक्रेता):',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      txn.collectorName ??
                          'कलेक्टर (#${txn.collectorId.length > 6 ? txn.collectorId.substring(0, 6) : txn.collectorId})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (txn.collectorPhone != null)
                      Text(
                        txn.collectorPhone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (txn.collectorAddress != null)
                      Text(
                        txn.collectorAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.recycling_outlined,
                size: 20,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'रीसाइक्लर (क्रेता):',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      txn.recyclerName ??
                          'रीसाइक्लर (#${txn.recyclerId.length > 6 ? txn.recyclerId.substring(0, 6) : txn.recyclerId})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (txn.recyclerPhone != null)
                      Text(
                        txn.recyclerPhone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (txn.recyclerAddress != null)
                      Text(
                        txn.recyclerAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(TransactionEntity txn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'वित्तीय एवं वजन विवरण',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _summaryRow(
            'कुल राशि',
            '₹${txn.amount.toStringAsFixed(0)}',
            isBold: true,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'प्लेटफ़ॉर्म शुल्क (5%)',
            '- ₹${txn.commission.platformFee.toStringAsFixed(0)}',
            textColor: const Color(0xFFC62828),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'शुद्ध देय राशि',
            '₹${txn.commission.netAmount.toStringAsFixed(0)}',
            isBold: true,
            textColor: const Color(0xFF1B5E20),
          ),
          const Divider(height: 20),
          _summaryRow(
            'वास्तविक वजन',
            '${txn.weightDetails.actualWeight.toStringAsFixed(1)} ${txn.weightDetails.weightUnit}',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'अनुमानित वजन',
            '${txn.weightDetails.estimatedWeight.toStringAsFixed(1)} ${txn.weightDetails.weightUnit}',
          ),
          if (txn.weightDetails.weightDifference != 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'वजन अंतर',
              '${txn.weightDetails.weightDifference > 0 ? "+" : ""}${txn.weightDetails.weightDifference.toStringAsFixed(1)} ${txn.weightDetails.weightUnit}',
            ),
          ],
          if (txn.notes != null && txn.notes!.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              'टिप्पणी: ${txn.notes!}',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHandoverCard(
    BuildContext context,
    TransactionDetailsLoaded state,
  ) {
    final txn = state.transaction;
    final isHandoverDone = txn.handoverDetails.isCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHandoverDone
              ? const Color(0xFFA5D6A7)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    color: Color(0xFF147A65),
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'हैंडओवर सत्यापन',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isHandoverDone
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isHandoverDone ? 'सत्यापित' : 'प्रतीक्षित',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isHandoverDone
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (isHandoverDone) ...[
            if (txn.handoverDetails.receivedBy != null)
              _summaryRow('प्राप्तकर्ता', txn.handoverDetails.receivedBy!),
            if (txn.handoverDetails.verifiedBy != null) ...[
              const SizedBox(height: 6),
              _summaryRow('सत्यापनकर्ता', txn.handoverDetails.verifiedBy!),
            ],
            if (txn.handoverDetails.handoverTime != null) ...[
              const SizedBox(height: 6),
              _summaryRow(
                'समय',
                '${txn.handoverDetails.handoverTime!.hour}:${txn.handoverDetails.handoverTime!.minute.toString().padLeft(2, '0')} (${txn.handoverDetails.handoverTime!.day}/${txn.handoverDetails.handoverTime!.month})',
              ),
            ],
            if (txn.handoverDetails.latitude != null &&
                txn.handoverDetails.longitude != null) ...[
              const SizedBox(height: 6),
              _summaryRow(
                'जीपीएस',
                '${txn.handoverDetails.latitude!.toStringAsFixed(4)}, ${txn.handoverDetails.longitude!.toStringAsFixed(4)}',
              ),
            ],
          ] else ...[
            const Text(
              'सामग्री प्राप्ति एवं सत्यापन विवरण दर्ज करें।',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.isSubmittingHandover
                    ? null
                    : () => _showHandoverModal(context, txn.id),
                icon: state.isSubmittingHandover
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_box_outlined),
                label: const Text('हैंडओवर विवरण दर्ज करें'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF147A65),
                  side: const BorderSide(color: Color(0xFF147A65)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    TransactionDetailsLoaded state,
  ) {
    final txn = state.transaction;
    final isPaid = txn.paymentStatus == PaymentStatus.completed;

    Color paymentBg;
    Color paymentFg;
    switch (txn.paymentStatus) {
      case PaymentStatus.completed:
        paymentBg = const Color(0xFFE8F5E9);
        paymentFg = const Color(0xFF1B5E20);
        break;
      case PaymentStatus.failed:
        paymentBg = const Color(0xFFFFEBEE);
        paymentFg = const Color(0xFFC62828);
        break;
      case PaymentStatus.pending:
        paymentBg = const Color(0xFFFFF3E0);
        paymentFg = const Color(0xFFE65100);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? const Color(0xFFA5D6A7) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.payment_outlined,
                    color: Color(0xFF147A65),
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'भुगतान स्थिति',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: paymentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  txn.paymentStatus.hindiLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: paymentFg,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _summaryRow('भुगतान विधि', txn.paymentMethod.hindiLabel),
          if (txn.paymentDetails.transactionId != null &&
              txn.paymentDetails.transactionId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _summaryRow('रेफरेंस आईडी', txn.paymentDetails.transactionId!),
          ],
          if (txn.completedAt != null) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'भुगतान समय',
              '${txn.completedAt!.hour}:${txn.completedAt!.minute.toString().padLeft(2, '0')} (${txn.completedAt!.day}/${txn.completedAt!.month}/${txn.completedAt!.year})',
            ),
          ],
          const SizedBox(height: 12),
          if (isPaid) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF1B5E20), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'भुगतान सफल! लेज़र (Ledger) में प्रविष्टियां दर्ज हो चुकी हैं।',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.isRecycler) ...[
            // Recycler-only payment trigger
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: state.isSubmittingPayment
                    ? null
                    : () => _showPaymentModal(context, txn.id),
                icon: state.isSubmittingPayment
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text(
                  'भुगतान दर्ज करें',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          ] else ...[
            // Collector view: notice that only recycler can record payment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: Color(0xFF6B7280)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'भुगतान केवल रीसाइक्लर द्वारा दर्ज किया जा सकता है। कृपया प्रतीक्षा करें।',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
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

  void _showHandoverModal(BuildContext context, String transactionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'हैंडओवर विवरण दर्ज करें',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _receivedByController,
                decoration: InputDecoration(
                  labelText: 'प्राप्तकर्ता का नाम',
                  hintText: 'सामग्री प्राप्त करने वाले का नाम',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _verifiedByController,
                decoration: InputDecoration(
                  labelText: 'सत्यापनकर्ता का नाम',
                  hintText: 'सामग्री जांचने वाले का नाम',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final received = _receivedByController.text.trim();
                    final verified = _verifiedByController.text.trim();
                    if (received.isEmpty && verified.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('कृपया कम से कम एक विवरण दर्ज करें'),
                          backgroundColor: Color(0xFFD32F2F),
                        ),
                      );
                      return;
                    }
                    Navigator.of(modalCtx).pop();
                    _bloc.add(
                      UpdateHandoverEvent(
                        transactionId: transactionId,
                        receivedBy: received.isNotEmpty ? received : null,
                        verifiedBy: verified.isNotEmpty ? verified : null,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF147A65),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('सहेजें'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentModal(BuildContext context, String transactionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'भुगतान स्थिति अपडेट करें',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'भुगतान की स्थिति:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('पूर्ण (Completed)'),
                        selected:
                            _selectedPaymentStatus == PaymentStatus.completed,
                        selectedColor: const Color(0xFFE8F5E9),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedPaymentStatus = PaymentStatus.completed;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('विफल (Failed)'),
                        selected:
                            _selectedPaymentStatus == PaymentStatus.failed,
                        selectedColor: const Color(0xFFFFEBEE),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedPaymentStatus = PaymentStatus.failed;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _paymentRefController,
                    decoration: InputDecoration(
                      labelText: 'रेफरेंस / ट्रांजैक्शन आईडी (वैकल्पिक)',
                      hintText: 'उदा. UPI Ref 123456789',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _receiptUrlController,
                    decoration: InputDecoration(
                      labelText: 'रसीद URL (वैकल्पिक)',
                      hintText: 'https://...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFE65100),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'भुगतान पूर्ण करने पर बैकएंड में लेज़र प्रविष्टि स्वतः दर्ज हो जाएगी।',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(modalCtx).pop();
                        _bloc.add(
                          UpdatePaymentEvent(
                            transactionId: transactionId,
                            paymentStatus: _selectedPaymentStatus.value,
                            paymentTransactionId:
                                _paymentRefController.text.trim().isNotEmpty
                                ? _paymentRefController.text.trim()
                                : null,
                            receiptUrl:
                                _receiptUrlController.text.trim().isNotEmpty
                                ? _receiptUrlController.text.trim()
                                : null,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('पुष्टि करें एवं सहेजें'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: isBold ? 15 : 14,
            color: textColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
