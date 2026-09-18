import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';
import '../../collector_dependency_container.dart';
import '../bloc/collector_transactions/collector_transactions_bloc.dart';
import '../bloc/collector_transactions/collector_transactions_event.dart';
import '../bloc/collector_transactions/collector_transactions_state.dart';

class CollectorTransactionsScreen extends StatefulWidget {
  final CollectorTransactionsBloc? bloc;

  const CollectorTransactionsScreen({super.key, this.bloc});

  @override
  State<CollectorTransactionsScreen> createState() =>
      _CollectorTransactionsScreenState();
}

class _CollectorTransactionsScreenState
    extends State<CollectorTransactionsScreen> {
  late final CollectorTransactionsBloc _bloc;
  bool _isLocalBloc = false;

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
      if (_bloc.state is CollectorTransactionsInitial) {
        _bloc.add(const FetchCollectorTransactionsEvent());
      }
    } else {
      _isLocalBloc = true;
      final container = CollectorDependencyContainer.fromApiClient(ApiClient());
      _bloc = container.createCollectorTransactionsBloc();
      _bloc.add(const FetchCollectorTransactionsEvent());
    }
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _bloc.close();
    }
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
            'मेरी कमाई और लेन-देन',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'रिफ्रेश करें',
              onPressed: () {
                _bloc.add(const FetchCollectorTransactionsEvent(refresh: true));
              },
            ),
          ],
        ),
        body: SafeArea(
          child:
              BlocBuilder<
                CollectorTransactionsBloc,
                CollectorTransactionsState
              >(
                builder: (context, state) {
                  if (state is CollectorTransactionsLoading ||
                      state is CollectorTransactionsInitial) {
                    return _buildLoadingState();
                  } else if (state is CollectorTransactionsFailure) {
                    return _buildFailureState(context, state.message);
                  } else if (state is CollectorTransactionsLoaded) {
                    return _buildLoadedState(context, state);
                  }
                  return const SizedBox.shrink();
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
          SizedBox(height: 16),
          Text(
            'लेन-देन लोड हो रहे हैं...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
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
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'लोड करने में समस्या हुई',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _bloc.add(const FetchCollectorTransactionsEvent(refresh: true));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('पुनः प्रयास करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF147A65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    CollectorTransactionsLoaded state,
  ) {
    return RefreshIndicator(
      color: const Color(0xFF147A65),
      onRefresh: () async {
        _bloc.add(const FetchCollectorTransactionsEvent(refresh: true));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildEarningsSummary(state),
          const SizedBox(height: 20),
          _buildFilterChips(state),
          const SizedBox(height: 16),
          if (state.transactions.isEmpty)
            _buildEmptyState()
          else
            ...state.transactions.map(
              (txn) => _buildTransactionCard(context, txn),
            ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary(CollectorTransactionsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'कमाई का सारांश',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF1B5E20),
                          size: 26,
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${state.totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'कुल कमाई',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.completedCount} सफल लेन-देन',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFE65100),
                          size: 26,
                        ),
                        Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFFEF6C00),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${state.pendingEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'भुगतान बाकी',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'रीसाइक्लर से प्रतीक्षित',
                      style: TextStyle(fontSize: 11, color: Color(0xFFF57C00)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips(CollectorTransactionsLoaded state) {
    final current = state.statusFilter ?? 'all';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            label: 'सभी',
            isSelected: current == 'all',
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('all')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'भुगतान पूरा',
            isSelected: current == 'completed',
            activeColor: const Color(0xFF1B5E20),
            activeBg: const Color(0xFFE8F5E9),
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('completed')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'भुगतान बाकी',
            isSelected: current == 'pending',
            activeColor: const Color(0xFFE65100),
            activeBg: const Color(0xFFFFF3E0),
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('pending')),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    Color activeColor = const Color(0xFF147A65),
    Color activeBg = const Color(0xFFE2F2EB),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'कोई लेन-देन नहीं मिला',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'जब आपका पूरा हुआ लॉट रीसाइक्लर द्वारा प्रोसेस किया जाएगा, उसका लेन-देन यहाँ दिखेगा।',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionEntity txn) {
    final net = txn.commission.netAmount > 0
        ? txn.commission.netAmount
        : (txn.amount -
              (txn.commission.platformFee > 0
                  ? txn.commission.platformFee
                  : txn.amount * 0.05));
    final displayNet = net > 0 ? net : txn.amount;

    Color badgeBg;
    Color badgeFg;
    IconData badgeIcon;
    String badgeText;

    switch (txn.paymentStatus) {
      case PaymentStatus.completed:
        badgeBg = const Color(0xFFE8F5E9);
        badgeFg = const Color(0xFF1B5E20);
        badgeIcon = Icons.check_circle;
        badgeText = 'भुगतान पूरा';
        break;
      case PaymentStatus.failed:
        badgeBg = const Color(0xFFFFEBEE);
        badgeFg = const Color(0xFFC62828);
        badgeIcon = Icons.cancel;
        badgeText = 'भुगतान विफल';
        break;
      case PaymentStatus.pending:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFE65100);
        badgeIcon = Icons.schedule;
        badgeText = 'भुगतान बाकी';
        break;
    }

    final lotRef = txn.lotId.length > 6
        ? txn.lotId.substring(txn.lotId.length - 6)
        : txn.lotId;

    final dateStr = txn.createdAt != null
        ? '${txn.createdAt!.day}/${txn.createdAt!.month}/${txn.createdAt!.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
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
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F2EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: Color(0xFF147A65),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn.notes != null && txn.notes!.isNotEmpty
                              ? txn.notes!
                              : 'कबाड़ लॉट',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'लॉट: #$lotRef  $dateStr',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${displayNet.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'शुद्ध राशि',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 14, color: badgeFg),
                        const SizedBox(width: 5),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: badgeFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'विवरण देखें',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
