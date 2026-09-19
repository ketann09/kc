import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/language_audio_sheet.dart';
import '../../../../core/widgets/speaker_button.dart';
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
    final l10n = context.l10n;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(
            l10n.myEarningsAndTransactions,
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
            BlocBuilder<CollectorTransactionsBloc, CollectorTransactionsState>(
              builder: (context, state) {
                if (state is CollectorTransactionsLoaded) {
                  return SpeakerButton(
                    textToSpeak:
                        '${l10n.myEarningsAndTransactions}. ${l10n.totalEarnings}: ₹${state.totalEarnings.toStringAsFixed(0)}. ${l10n.paymentPending}: ₹${state.pendingEarnings.toStringAsFixed(0)}.',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.retry,
              onPressed: () {
                _bloc.add(const FetchCollectorTransactionsEvent(refresh: true));
              },
            ),
          ],
        ),
        body: SafeArea(
          child:
              BlocBuilder<CollectorTransactionsBloc, CollectorTransactionsState>(
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
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: Color(0xFF147A65), strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            l10n.loading,
            style: const TextStyle(
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
    final l10n = context.l10n;
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
            Text(
              l10n.lotsLoadError,
              style: const TextStyle(
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
              label: Text(l10n.retry),
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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.earningsSummary,
          style: const TextStyle(
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
                    Text(
                      l10n.totalEarnings,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.isMarathi
                          ? '${state.completedCount} यशस्वी व्यवहार'
                          : '${state.completedCount} सफल लेन-देन',
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
                    Text(
                      l10n.paymentPending,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.isMarathi
                          ? 'रीसायकलरकडून प्रतीक्षेत'
                          : 'रीसाइक्लर से प्रतीक्षित',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFF57C00)),
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
    final l10n = context.l10n;
    final current = state.statusFilter ?? 'all';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            label: l10n.allTransactions,
            isSelected: current == 'all',
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('all')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: l10n.paymentCompleted,
            isSelected: current == 'completed',
            activeColor: const Color(0xFF1B5E20),
            activeBg: const Color(0xFFE8F5E9),
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('completed')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: l10n.paymentPending,
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
    final l10n = context.l10n;
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
          Text(
            l10n.noTransactionsFound,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.isMarathi
                ? 'तुमचा पूर्ण झालेला लॉट रीसायकलरद्वारे प्रक्रिया केल्यावर, त्याचा व्यवहार येथे दिसेल.'
                : 'जब आपका पूरा हुआ लॉट रीसाइक्लर द्वारा प्रोसेस किया जाएगा, उसका लेन-देन यहाँ दिखेगा।',
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    final l10n = context.l10n;
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
        badgeText = l10n.paymentCompleted;
        break;
      case PaymentStatus.failed:
        badgeBg = const Color(0xFFFFEBEE);
        badgeFg = const Color(0xFFC62828);
        badgeIcon = Icons.cancel;
        badgeText = l10n.paymentFailed;
        break;
      case PaymentStatus.pending:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFE65100);
        badgeIcon = Icons.schedule;
        badgeText = l10n.paymentPending;
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
                              : (context.isMarathi
                                  ? 'कबाडी लॉट'
                                  : 'कबाड़ लॉट'),
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
                      Text(
                        l10n.netPayable,
                        style: const TextStyle(
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
                        l10n.viewDetails,
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
