import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/read_cache_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_audio_sheet.dart';
import '../../../../core/widgets/offline_stale_banner.dart';
import '../../../../core/widgets/speaker_button.dart';
import '../../../../domain/entities/lot_entity.dart';
import '../../collector_dependency_container.dart';
import '../bloc/collector_lots/collector_lots_bloc.dart';
import '../bloc/collector_lots/collector_lots_event.dart';
import '../bloc/collector_lots/collector_lots_state.dart';

enum _LotFilterTab { all, pending, inProgress, completed }

class CollectorLotsScreen extends StatelessWidget {
  const CollectorLotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<CollectorLotsBloc>();
      return const _CollectorLotsView();
    } catch (_) {
      return BlocProvider<CollectorLotsBloc>(
        create: (ctx) {
          ApiClient apiClient;
          try {
            apiClient = ctx.read<ApiClient>();
          } catch (_) {
            apiClient = ApiClient();
          }
          ReadCacheStorage? readCache;
          try {
            readCache = ctx.read<ReadCacheStorage>();
          } catch (_) {}
          final container = CollectorDependencyContainer.fromApiClient(
            apiClient,
            readCacheStorage: readCache,
          );
          return container.createCollectorLotsBloc()
            ..add(const CollectorLotsFetchRequested(refresh: true));
        },
        child: const _CollectorLotsView(),
      );
    }
  }
}

class _CollectorLotsView extends StatefulWidget {
  const _CollectorLotsView();

  @override
  State<_CollectorLotsView> createState() => _CollectorLotsViewState();
}

class _CollectorLotsViewState extends State<_CollectorLotsView> {
  _LotFilterTab _selectedTab = _LotFilterTab.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<CollectorLotsBloc>();
        if (bloc.state is! CollectorLotsLoaded &&
            bloc.state is! CollectorLotsLoading) {
          bloc.add(const CollectorLotsFetchRequested(refresh: true));
        }
      }
    });
  }

  List<LotEntity> _filterLots(List<LotEntity> lots) {
    switch (_selectedTab) {
      case _LotFilterTab.pending:
        return lots.where((l) => l.status == LotStatus.pending).toList();
      case _LotFilterTab.inProgress:
        return lots
            .where(
              (l) =>
                  l.status == LotStatus.accepted ||
                  l.status == LotStatus.picked ||
                  l.status == LotStatus.delivered,
            )
            .toList();
      case _LotFilterTab.completed:
        return lots.where((l) => l.status == LotStatus.completed).toList();
      case _LotFilterTab.all:
        return lots;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          l10n.myLotsAction,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.dark900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark900,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          InkWell(
            onTap: () => LanguageAudioSheet.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greenPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    size: 15,
                    color: AppColors.greenPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.currentLanguage.nativeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<CollectorLotsBloc, CollectorLotsState>(
            builder: (context, state) {
              final isOffline = state is CollectorLotsLoaded && state.isOffline;
              final prefix = isOffline ? '${l10n.offlineStaleNotice}। ' : '';
              return SpeakerButton(textToSpeak: '$prefix${l10n.myRecentLots}.');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<CollectorLotsBloc, CollectorLotsState>(
              builder: (context, state) {
                if (state is CollectorLotsLoaded && state.isOffline) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OfflineStaleBanner(
                      cachedAt: state.cachedAt,
                      isRefreshing: state.isRefreshing,
                      onRefresh: () => context.read<CollectorLotsBloc>().add(
                        const CollectorLotsFetchRequested(refresh: true),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildFilterTabBar(),
            Expanded(
              child: BlocBuilder<CollectorLotsBloc, CollectorLotsState>(
                builder: (context, state) {
                  if (state is CollectorLotsLoading ||
                      state is CollectorLotsInitial) {
                    return _buildLoadingState();
                  } else if (state is CollectorLotsFailure) {
                    return _buildFailureState(context, state.message);
                  } else if (state is CollectorLotsLoaded) {
                    final filtered = _filterLots(state.lots);
                    if (filtered.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildLoadedList(context, filtered);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabBar() {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(l10n.allLots, _LotFilterTab.all),
            const SizedBox(width: 8),
            _buildFilterChip(l10n.statusPending, _LotFilterTab.pending),
            const SizedBox(width: 8),
            _buildFilterChip(l10n.inProgressLots, _LotFilterTab.inProgress),
            const SizedBox(width: 8),
            _buildFilterChip(l10n.statusCompleted, _LotFilterTab.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, _LotFilterTab tab) {
    final isSelected = _selectedTab == tab;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.dark700,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.saffronPrimary,
      backgroundColor: AppColors.saffron50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.saffronPrimary : AppColors.saffron200,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTab = tab;
          });
        }
      },
    );
  }

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
            l10n.lotsLoading,
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
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CollectorLotsBloc>().add(
                  const CollectorLotsFetchRequested(refresh: true),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: AppColors.saffron50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.saffronPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noLotsFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noScrapLotsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.dark500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/new-lot');
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createNewLotButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedList(BuildContext context, List<LotEntity> lots) {
    return RefreshIndicator(
      color: AppColors.saffronPrimary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        context.read<CollectorLotsBloc>().add(
          const CollectorLotsFetchRequested(refresh: true),
        );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lots.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _CollectorLotCard(lot: lots[index]);
        },
      ),
    );
  }
}

class _CollectorLotCard extends StatelessWidget {
  final LotEntity lot;

  const _CollectorLotCard({required this.lot});

  @override
  Widget build(BuildContext context) {
    final title = (lot.materialName != null && lot.materialName!.isNotEmpty)
        ? lot.materialName!
        : (lot.mlPrediction?.predictedCategory != null &&
              lot.mlPrediction!.predictedCategory!.isNotEmpty)
        ? lot.mlPrediction!.predictedCategory!
        : (lot.description != null && lot.description!.isNotEmpty)
        ? lot.description!
        : (context.isMarathi ? 'कबाडी लॉट' : 'कबाड़ लॉट');

    final weight = lot.actualWeight ?? lot.estimatedWeight;
    final unit = context.l10n.kgUnit;
    final weightStr =
        '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} $unit';

    final effectivePrice = lot.finalPrice ?? lot.estimatedPrice;
    final priceStr = effectivePrice > 0
        ? '₹${effectivePrice.toStringAsFixed(0)}'
        : (context.isMarathi ? 'किंमत प्रतीक्षेत' : 'मूल्य प्रतीक्षित');

    final (statusBg, statusFg, statusIcon, statusText) = _getStatusConfig(
      context,
      lot.status,
    );

    final dateStr = lot.createdAt != null
        ? DateFormat('dd MMM yyyy').format(lot.createdAt!)
        : (context.isMarathi ? 'अलीकडे' : 'हाल ही में');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/collector-lot-details',
            arguments: {'lotId': lot.id, 'lot': lot},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderMedium),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
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
                      color: AppColors.saffron50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: AppColors.saffronPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.dark500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusFg),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.scale_rounded,
                        size: 16,
                        color: AppColors.dark400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        weightStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        priceStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greenPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.dark400,
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

  (Color, Color, IconData, String) _getStatusConfig(
    BuildContext context,
    LotStatus status,
  ) {
    final l10n = context.l10n;
    switch (status) {
      case LotStatus.pending:
        return (
          AppColors.amber50,
          AppColors.amberPrimary,
          Icons.hourglass_top_rounded,
          l10n.statusPending,
        );
      case LotStatus.accepted:
        return (
          const Color(0xFFEFF6FF),
          const Color(0xFF2563EB),
          Icons.handshake_outlined,
          l10n.statusAccepted,
        );
      case LotStatus.picked:
        return (
          const Color(0xFFF5F3FF),
          const Color(0xFF7C3AED),
          Icons.local_shipping_outlined,
          l10n.statusPicked,
        );
      case LotStatus.delivered:
        return (
          const Color(0xFFFDF2F8),
          const Color(0xFFDB2777),
          Icons.inventory_2_outlined,
          l10n.statusDelivered,
        );
      case LotStatus.completed:
        return (
          AppColors.green50,
          AppColors.greenPrimary,
          Icons.check_circle_outline_rounded,
          l10n.statusCompleted,
        );
      case LotStatus.cancelled:
        return (
          const Color(0xFFFEF2F2),
          const Color(0xFFDC2626),
          Icons.cancel_outlined,
          l10n.statusCancelled,
        );
    }
  }
}
