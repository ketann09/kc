import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/read_cache_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/language_audio_sheet.dart';
import '../../../../core/widgets/offline_stale_banner.dart';
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
      ApiClient apiClient;
      try {
        apiClient = context.read<ApiClient>();
      } catch (_) {
        apiClient = ApiClient();
      }
      ReadCacheStorage? readCache;
      try {
        readCache = context.read<ReadCacheStorage>();
      } catch (_) {}
      final container = CollectorDependencyContainer.fromApiClient(
        apiClient,
        readCacheStorage: readCache,
      );
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
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            l10n.myEarningsAndTransactions,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.dark900,
            ),
          ),
          centerTitle: true,
          actions: [
            // Language audio pill — saffron brand style
            InkWell(
              onTap: () => LanguageAudioSheet.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.saffron100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.saffronPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 15,
                      color: AppColors.saffronDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.currentLanguage.nativeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.saffronDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TTS speaker — only in loaded state
            BlocBuilder<CollectorTransactionsBloc, CollectorTransactionsState>(
              builder: (context, state) {
                if (state is CollectorTransactionsLoaded) {
                  final isOffline = state.isOffline;
                  final prefix = isOffline
                      ? '${l10n.offlineStaleNotice}। '
                      : '';
                  return SpeakerButton(
                    textToSpeak:
                        '$prefix${l10n.myEarningsAndTransactions}. ${l10n.totalEarnings}: ₹${state.totalEarnings.toStringAsFixed(0)}. ${l10n.paymentPending}: ₹${state.pendingEarnings.toStringAsFixed(0)}.',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Refresh icon button
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.dark700),
              tooltip: l10n.retry,
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

  // ─── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.saffronPrimary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Failure ────────────────────────────────────────────────────────────────

  Widget _buildFailureState(BuildContext context, String message) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.red100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.lotsLoadError,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.dark500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  _bloc.add(
                    const FetchCollectorTransactionsEvent(refresh: true),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loaded ─────────────────────────────────────────────────────────────────

  Widget _buildLoadedState(
    BuildContext context,
    CollectorTransactionsLoaded state,
  ) {
    return RefreshIndicator(
      color: AppColors.saffronPrimary,
      onRefresh: () async {
        _bloc.add(const FetchCollectorTransactionsEvent(refresh: true));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          if (state.isOffline)
            OfflineStaleBanner(
              cachedAt: state.cachedAt,
              isRefreshing: state.isRefreshing,
              onRefresh: () => _bloc.add(
                const FetchCollectorTransactionsEvent(refresh: true),
              ),
            ),
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

  // ─── Earnings Summary ───────────────────────────────────────────────────────

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
            color: AppColors.dark900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Total Earnings — India Green
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.greenPrimary.withValues(alpha: 0.35),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0816A34A),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.green700,
                          size: 26,
                        ),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.greenPrimary,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${state.totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.totalEarnings,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.isMarathi
                          ? '${state.completedCount} यशस्वी व्यवहार'
                          : '${state.completedCount} सफल लेन-देन',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.greenPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Pending Earnings — Amber
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.amberPrimary.withValues(alpha: 0.35),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08D97706),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: AppColors.amber700,
                          size: 26,
                        ),
                        Icon(
                          Icons.schedule_rounded,
                          color: AppColors.amberPrimary,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${state.pendingEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.amber700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.paymentPending,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.isMarathi
                          ? 'रीसायकलरकडून प्रतीक्षेत'
                          : 'रीसाइक्लर से प्रतीक्षित',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.amberPrimary.withValues(alpha: 0.8),
                      ),
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

  // ─── Filter Chips ───────────────────────────────────────────────────────────

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
            activeColor: AppColors.saffronPrimary,
            activeBg: AppColors.saffron100,
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('all')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: l10n.paymentCompleted,
            isSelected: current == 'completed',
            activeColor: AppColors.greenPrimary,
            activeBg: AppColors.green100,
            onTap: () =>
                _bloc.add(const FilterCollectorTransactionsEvent('completed')),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: l10n.paymentPending,
            isSelected: current == 'pending',
            activeColor: AppColors.amberPrimary,
            activeBg: AppColors.amber100,
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
    Color activeColor = AppColors.saffronPrimary,
    Color activeBg = AppColors.saffron100,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderMedium,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : AppColors.dark600,
          ),
        ),
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: const Icon(
        Icons.receipt_long_outlined,
        size: 32,
        color: AppColors.saffronPrimary,
      ),
      title: l10n.noTransactionsFound,
      description: context.isMarathi
          ? 'तुमचा पूर्ण झालेला लॉट रीसायकलरद्वारे प्रक्रिया केल्यावर, त्याचा व्यवहार येथे दिसेल.'
          : 'जब आपका पूरा हुआ लॉट रीसाइक्लर द्वारा प्रोसेस किया जाएगा, उसका लेन-देन यहाँ दिखेगा।',
    );
  }

  // ─── Transaction Card ────────────────────────────────────────────────────────

  Widget _buildTransactionCard(BuildContext context, TransactionEntity txn) {
    final l10n = context.l10n;

    // Resolve net display amount
    final net = txn.commission.netAmount > 0
        ? txn.commission.netAmount
        : (txn.amount -
              (txn.commission.platformFee > 0
                  ? txn.commission.platformFee
                  : txn.amount * 0.05));
    final displayNet = net > 0 ? net : txn.amount;

    // Status badge tokens
    Color badgeBg;
    Color badgeFg;
    IconData badgeIcon;
    String badgeText;

    switch (txn.paymentStatus) {
      case PaymentStatus.completed:
        badgeBg = AppColors.green100;
        badgeFg = AppColors.green700;
        badgeIcon = Icons.check_circle;
        badgeText = l10n.paymentCompleted;
        break;
      case PaymentStatus.failed:
        badgeBg = AppColors.red100;
        badgeFg = AppColors.redPrimary;
        badgeIcon = Icons.cancel;
        badgeText = l10n.paymentFailed;
        break;
      case PaymentStatus.pending:
        badgeBg = AppColors.amber100;
        badgeFg = AppColors.amber700;
        badgeIcon = Icons.schedule;
        badgeText = l10n.paymentPending;
        break;
    }

    // Short lot reference
    final lotRef = txn.lotId.length > 6
        ? txn.lotId.substring(txn.lotId.length - 6)
        : txn.lotId;

    final dateStr = txn.createdAt != null
        ? '${txn.createdAt!.day}/${txn.createdAt!.month}/${txn.createdAt!.year}'
        : '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon / title / amount ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recycling icon avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.saffron100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: AppColors.saffronDark,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // Title + lot ref
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.notes != null && txn.notes!.isNotEmpty
                            ? txn.notes!
                            : (context.isMarathi ? 'कबाडी लॉट' : 'कबाड़ लॉट'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'लॉट: #$lotRef  $dateStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.dark500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Net amount (right-aligned)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${displayNet.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.netPayable,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.dark500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 12),
            // ── Bottom row: status badge / view details ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Payment status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                // View details link
                Row(
                  children: [
                    Text(
                      l10n.viewDetails,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.saffronDark,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.saffronDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
