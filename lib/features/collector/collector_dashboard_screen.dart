import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/bloc/accessibility/accessibility_bloc.dart';
import '../../core/bloc/accessibility/accessibility_event.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/language_audio_sheet.dart';
import '../../domain/entities/lot_entity.dart';
import '../../domain/entities/material_entity.dart';
import 'collector_dependency_container.dart';
import 'presentation/bloc/collector_lots/collector_lots_bloc.dart';
import 'presentation/bloc/collector_lots/collector_lots_event.dart';
import 'presentation/bloc/collector_lots/collector_lots_state.dart';

class CollectorDashboardScreen extends StatelessWidget {
  const CollectorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<CollectorLotsBloc>();
      return const _CollectorDashboardView();
    } catch (_) {
      return BlocProvider<CollectorLotsBloc>(
        create: (ctx) {
          ApiClient apiClient;
          try {
            apiClient = ctx.read<ApiClient>();
          } catch (_) {
            apiClient = ApiClient();
          }
          final container = CollectorDependencyContainer.fromApiClient(
            apiClient,
          );
          return container.createCollectorLotsBloc()
            ..add(const CollectorDashboardInitRequested());
        },
        child: const _CollectorDashboardView(),
      );
    }
  }
}

class _CollectorDashboardView extends StatefulWidget {
  const _CollectorDashboardView();

  @override
  State<_CollectorDashboardView> createState() =>
      _CollectorDashboardViewState();
}

class _CollectorDashboardViewState extends State<_CollectorDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<CollectorLotsBloc>();
        if (bloc.state is! CollectorDashboardLoaded &&
            bloc.state is! CollectorLotsLoading) {
          bloc.add(const CollectorDashboardInitRequested());
        }
      }
    });
  }

  static String _getCategoryLocalized(BuildContext context, String category) {
    final l10n = context.l10n;
    switch (category.toLowerCase()) {
      case 'pcb':
      case 'e-waste':
      case 'electronics':
        return l10n.categoryPcb;
      case 'battery':
        return l10n.categoryBattery;
      case 'cable':
      case 'copper':
      case 'metal':
      case 'wire':
        return l10n.categoryCable;
      case 'plastic':
        return l10n.categoryPlastic;
      case 'paper':
      case 'cardboard':
        return l10n.categoryPaper;
      case 'glass':
        return l10n.categoryGlass;
      default:
        return category.isNotEmpty ? category : l10n.categoryOther;
    }
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pcb':
      case 'e-waste':
      case 'electronics':
        return Icons.memory_rounded;
      case 'battery':
        return Icons.battery_full_rounded;
      case 'cable':
      case 'copper':
      case 'metal':
      case 'wire':
        return Icons.cable_rounded;
      case 'plastic':
        return Icons.recycling_rounded;
      case 'paper':
      case 'cardboard':
        return Icons.description_outlined;
      case 'glass':
        return Icons.wine_bar_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  static int _getBenchmarkRate(String category, String name) {
    final cat = category.toLowerCase();
    final n = name.toLowerCase();
    if (cat.contains('e-waste') ||
        cat.contains('pcb') ||
        n.contains('pcb') ||
        n.contains('ई-कचरा') ||
        n.contains('कचरा')) {
      return 210;
    }
    if (cat.contains('battery') ||
        n.contains('battery') ||
        n.contains('बैटरी') ||
        n.contains('बॅटरी')) {
      return 85;
    }
    if (cat.contains('cable') ||
        cat.contains('metal') ||
        cat.contains('copper') ||
        n.contains('cable') ||
        n.contains('केबल') ||
        n.contains('धातु') ||
        n.contains('तांबे')) {
      return 140;
    }
    if (cat.contains('plastic') ||
        n.contains('plastic') ||
        n.contains('प्लास्टिक')) {
      return 22;
    }
    if (cat.contains('paper') ||
        n.contains('paper') ||
        n.contains('कागज') ||
        n.contains('कागद')) {
      return 15;
    }
    return 50;
  }

  List<_ScrapRate> _resolveRates(
      BuildContext context, List<MaterialEntity> liveRates) {
    final l10n = context.l10n;
    if (liveRates.isEmpty) {
      if (context.isMarathi) {
        return [
          _ScrapRate(
            name: 'पीसीबी',
            subtitle: l10n.perKg,
            price: 210,
            icon: Icons.memory_rounded,
          ),
          _ScrapRate(
            name: 'बॅटरी',
            subtitle: l10n.perKg,
            price: 85,
            icon: Icons.battery_full_rounded,
          ),
          _ScrapRate(
            name: 'केबल',
            subtitle: l10n.perKg,
            price: 140,
            icon: Icons.cable_rounded,
          ),
          _ScrapRate(
            name: 'मिश्रित प्लास्टिक',
            subtitle: l10n.perKg,
            price: 22,
            icon: Icons.recycling_rounded,
          ),
        ];
      } else if (context.isEnglish) {
        return [
          _ScrapRate(
            name: 'PCB',
            subtitle: l10n.perKg,
            price: 210,
            icon: Icons.memory_rounded,
          ),
          _ScrapRate(
            name: 'Battery',
            subtitle: l10n.perKg,
            price: 85,
            icon: Icons.battery_full_rounded,
          ),
          _ScrapRate(
            name: 'Cable',
            subtitle: l10n.perKg,
            price: 140,
            icon: Icons.cable_rounded,
          ),
          _ScrapRate(
            name: 'Mixed Plastic',
            subtitle: l10n.perKg,
            price: 22,
            icon: Icons.recycling_rounded,
          ),
        ];
      }
      return [
        _ScrapRate(
          name: 'पीसीबी',
          subtitle: l10n.perKg,
          price: 210,
          icon: Icons.memory_rounded,
        ),
        _ScrapRate(
          name: 'बैटरी',
          subtitle: l10n.perKg,
          price: 85,
          icon: Icons.battery_full_rounded,
        ),
        _ScrapRate(
          name: 'केबल',
          subtitle: l10n.perKg,
          price: 140,
          icon: Icons.cable_rounded,
        ),
        _ScrapRate(
          name: 'मिश्रित प्लास्टिक',
          subtitle: l10n.perKg,
          price: 22,
          icon: Icons.recycling_rounded,
        ),
      ];
    }
    return liveRates.map((m) {
      final name = _getCategoryLocalized(
          context, m.name.isNotEmpty ? m.name : m.category);
      final price = _getBenchmarkRate(m.category, m.name);
      final icon = _getCategoryIcon(m.category);
      return _ScrapRate(
        name: name,
        subtitle: l10n.perKg,
        price: price,
        icon: icon,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CollectorLotsBloc, CollectorLotsState>(
          builder: (context, state) {
            if (state is CollectorLotsLoading ||
                state is CollectorLotsInitial) {
              return _buildLoadingState(context);
            } else if (state is CollectorLotsFailure) {
              return _buildFailureState(context, state.message);
            }

            List<LotEntity> recentLots = [];
            List<MaterialEntity> liveRates = [];

            if (state is CollectorDashboardLoaded) {
              recentLots = state.recentLots;
              liveRates = state.liveRates;
            } else if (state is CollectorLotsLoaded) {
              recentLots = state.lots.take(5).toList();
            }

            final resolvedRates = _resolveRates(context, liveRates);

            return RefreshIndicator(
              color: const Color(0xFF147A65),
              onRefresh: () async {
                context.read<CollectorLotsBloc>().add(
                  const CollectorDashboardInitRequested(),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(context, recentLots),
                    const SizedBox(height: 24),
                    _buildRecentLotsSection(context, recentLots),
                    const SizedBox(height: 28),
                    _buildLiveRatesSection(context, resolvedRates),
                    const SizedBox(height: 24),
                    _buildBottomActions(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<LotEntity> recentLots) {
    final l10n = context.l10n;

    return Row(
      children: [
        if (Navigator.canPop(context))
          _BackButton(onPressed: () => Navigator.pop(context))
        else
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F2EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
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
                l10n.welcomeGreeting,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.dashboardSubtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
        // Language Switcher Chip
        InkWell(
          onTap: () => LanguageAudioSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                const Icon(Icons.language, size: 16, color: Color(0xFF2E7D32)),
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
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/collector-lots');
          },
          tooltip: l10n.myRecentLots,
          icon: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF147A65),
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/collector-transactions');
          },
          tooltip: l10n.myEarningsAndTransactions,
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF147A65),
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () {
            final speechText =
                '${l10n.welcomeGreeting}. ${l10n.todayRatesTitle}. ${recentLots.length} ${l10n.myRecentLots}.';
            try {
              context.read<AccessibilityBloc>().add(
                    AccessibilitySpeakRequested(speechText, force: true),
                  );
            } catch (_) {}
          },
          tooltip: l10n.audioTooltip,
          icon: const Icon(
            Icons.volume_up_outlined,
            color: Color(0xFF147A65),
            size: 23,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLotsSection(
    BuildContext context,
    List<LotEntity> recentLots,
  ) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myRecentLots,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF191919),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/collector-lots');
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFF147A65),
              ),
              label: Text(
                l10n.viewAll,
                style: const TextStyle(
                  color: Color(0xFF147A65),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentLots.isEmpty)
          _buildEmptyRecentLotsCard(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLots.length > 3 ? 3 : recentLots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildRecentLotCard(context, recentLots[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyRecentLotsCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 38,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.noScrapLots,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noScrapLotsSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/new-lot');
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addFirstLotAction),
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
    );
  }

  Widget _buildRecentLotCard(BuildContext context, LotEntity lot) {
    final rawCategory =
        lot.materialName ??
        lot.mlPrediction?.predictedCategory ??
        lot.description ??
        '';
    final categoryName = _getCategoryLocalized(context, rawCategory);
    final weight = lot.actualWeight ?? lot.estimatedWeight;
    final isWholeNumber = weight.truncateToDouble() == weight;
    final weightText = '${weight.toStringAsFixed(isWholeNumber ? 0 : 1)} kg';
    final price =
        lot.finalPrice ?? (lot.estimatedPrice > 0 ? lot.estimatedPrice : null);
    final priceText = price != null ? '₹${price.toStringAsFixed(0)}' : null;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/collector-lot-details',
          arguments: {'lotId': lot.id, 'lot': lot},
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F5),
          border: Border.all(color: const Color(0xFFE1E1DC)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE2F2EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(rawCategory),
                color: const Color(0xFF147A65),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildLotStatusBadge(context, lot.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        weightText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                      if (priceText != null) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF147A65),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotStatusBadge(BuildContext context, LotStatus status) {
    final l10n = context.l10n;
    Color textColor;
    Color bgColor;
    String label;
    IconData icon;

    switch (status) {
      case LotStatus.pending:
        textColor = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        label = l10n.statusPending;
        icon = Icons.schedule_rounded;
        break;
      case LotStatus.accepted:
        textColor = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        label = l10n.statusAccepted;
        icon = Icons.thumb_up_alt_outlined;
        break;
      case LotStatus.picked:
        textColor = const Color(0xFF6A1B9A);
        bgColor = const Color(0xFFF3E5F5);
        label = l10n.statusPicked;
        icon = Icons.local_shipping_outlined;
        break;
      case LotStatus.delivered:
        textColor = const Color(0xFF00695C);
        bgColor = const Color(0xFFE0F2F1);
        label = l10n.statusDelivered;
        icon = Icons.domain_verification_outlined;
        break;
      case LotStatus.completed:
        textColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        label = l10n.statusCompleted;
        icon = Icons.check_circle_outline_rounded;
        break;
      case LotStatus.cancelled:
        textColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        label = l10n.statusCancelled;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRatesSection(BuildContext context, List<_ScrapRate> rates) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF147A65),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.todayRatesTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF191919),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F2EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.liveStatus,
                style: const TextStyle(
                  color: Color(0xFF147A65),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _RateCard(rate: rates[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Earnings & Transactions CTA
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/collector-transactions');
            },
            icon: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF147A65),
              size: 20,
            ),
            label: Text(
              l10n.myEarningsAndTransactions,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF147A65),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF147A65), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // New lot CTA
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/new-lot');
            },
            icon: const Icon(Icons.add_rounded, size: 22),
            label: Text(
              l10n.newScrapLotAction,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF147A65),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF147A65)),
          const SizedBox(height: 16),
          Text(
            l10n.collectorDashboardLoading,
            style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(BuildContext context, String message) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.collectorDashboardLoadError,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CollectorLotsBloc>().add(
                  const CollectorDashboardInitRequested(),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
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
}

class _RateCard extends StatelessWidget {
  final _ScrapRate rate;

  const _RateCard({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F5),
        border: Border.all(color: const Color(0xFFE1E1DC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F2EB),
              shape: BoxShape.circle,
            ),
            child: Icon(rate.icon, size: 21, color: const Color(0xFF147A65)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rate.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${rate.price}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '/kg',
            style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF222222), width: 1.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 22),
      ),
    );
  }
}

class _ScrapRate {
  final String name;
  final String subtitle;
  final int price;
  final IconData icon;

  const _ScrapRate({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}
