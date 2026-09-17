import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/lot_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_state.dart';
import 'presentation/bloc/recycler_dashboard_bloc.dart';
import 'presentation/bloc/recycler_dashboard_event.dart';
import 'presentation/bloc/recycler_dashboard_state.dart';
import 'recycler_dependency_container.dart';

class RecyclerDashboardScreen extends StatelessWidget {
  const RecyclerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RecyclerDashboardBloc>();
      return const _RecyclerDashboardView();
    } catch (_) {
      return BlocProvider<RecyclerDashboardBloc>(
        create: (ctx) {
          ApiClient apiClient;
          try {
            apiClient = ctx.read<ApiClient>();
          } catch (_) {
            apiClient = ApiClient();
          }
          final container = RecyclerDependencyContainer.fromApiClient(
            apiClient,
          );
          final bloc = container.createRecyclerDashboardBloc();

          bool isAuthenticated = true;
          try {
            final authBloc = ctx.read<AuthBloc>();
            if (authBloc.state is! Authenticated) {
              isAuthenticated = false;
            }
          } catch (_) {}

          if (isAuthenticated) {
            bloc.add(const FetchIncomingLots(page: 1));
          }
          return bloc;
        },
        child: const _RecyclerDashboardView(),
      );
    }
  }
}

class _RecyclerDashboardView extends StatefulWidget {
  const _RecyclerDashboardView();

  @override
  State<_RecyclerDashboardView> createState() => _RecyclerDashboardViewState();
}

class _RecyclerDashboardViewState extends State<_RecyclerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<RecyclerDashboardBloc>();
        if (bloc.state is RecyclerDashboardInitial) {
          bool isAuthenticated = true;
          try {
            final authBloc = context.read<AuthBloc>();
            if (authBloc.state is! Authenticated) {
              isAuthenticated = false;
            }
          } catch (_) {}

          if (isAuthenticated) {
            bloc.add(const FetchIncomingLots(page: 1));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'नए लॉट अनुरोध',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocBuilder<RecyclerDashboardBloc, RecyclerDashboardState>(
          builder: (context, state) {
            if (state is RecyclerDashboardLoading ||
                state is RecyclerDashboardInitial) {
              return _buildLoadingState();
            } else if (state is RecyclerDashboardFailure) {
              return _buildFailureState(context, state.message);
            } else if (state is RecyclerDashboardEmpty) {
              return _buildEmptyState(context);
            } else if (state is RecyclerDashboardLoaded) {
              return _buildLotsList(context, state.lots);
            }
            return const SizedBox.shrink();
          },
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
            'लॉट लोड हो रहे हैं...',
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
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'लॉट लोड करने में समस्या',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
            ElevatedButton.icon(
              onPressed: () {
                context.read<RecyclerDashboardBloc>().add(
                  const FetchIncomingLots(page: 1, refresh: true),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('पुनः प्रयास करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF147A65),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
    return Center(
      child: RefreshIndicator(
        color: const Color(0xFF147A65),
        onRefresh: () async {
          context.read<RecyclerDashboardBloc>().add(
            const FetchIncomingLots(page: 1, refresh: true),
          );
        },
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(32),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF5EF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Color(0xFF147A65),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'अभी कोई नया लॉट नहीं है',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'नए लॉट अनुरोध यहाँ दिखाई देंगे।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<RecyclerDashboardBloc>().add(
                    const FetchIncomingLots(page: 1, refresh: true),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('रिफ्रेश करें'),
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
        ),
      ),
    );
  }

  Widget _buildLotsList(BuildContext context, List<LotEntity> lots) {
    return RefreshIndicator(
      color: const Color(0xFF147A65),
      onRefresh: () async {
        context.read<RecyclerDashboardBloc>().add(
          const FetchIncomingLots(page: 1, refresh: true),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: lots.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'आपके पास आने वाले कलेक्टर के लॉट',
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
            );
          }

          final lot = lots[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _LotCard(
              lot: lot,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/incoming-lot',
                  arguments: lot.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final LotEntity lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final materialTitle =
        (lot.materialName != null && lot.materialName!.isNotEmpty)
        ? lot.materialName!
        : (lot.mlPrediction?.predictedCategory != null &&
              lot.mlPrediction!.predictedCategory!.isNotEmpty)
        ? lot.mlPrediction!.predictedCategory!
        : (lot.description != null && lot.description!.isNotEmpty)
        ? lot.description!
        : 'स्क्रैप लॉट';

    final priceText = lot.estimatedPrice > 0
        ? '₹${lot.estimatedPrice.toStringAsFixed(0)}'
        : 'मूल्य प्रतीक्षित';

    final weight = lot.actualWeight ?? lot.estimatedWeight;
    final weightText = weight >= 1.0
        ? '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} किलो'
        : '${(weight * 1000).toStringAsFixed(0)} ग्राम';

    final collectorInfo =
        (lot.collectorName != null && lot.collectorName!.isNotEmpty)
        ? '${lot.collectorName!} द्वारा भेजा गया'
        : 'कलेक्टर द्वारा भेजा गया';

    final locationText =
        (lot.location.city != null && lot.location.city!.isNotEmpty)
        ? (lot.location.state != null && lot.location.state!.isNotEmpty
              ? '${lot.location.city}, ${lot.location.state}'
              : lot.location.city!)
        : (lot.location.address != null && lot.location.address!.isNotEmpty
              ? lot.location.address!
              : null);

    final isPickup = lot.schedulePickup != null;

    String statusHindi;
    switch (lot.status) {
      case LotStatus.pending:
        statusHindi = 'लंबित';
        break;
      case LotStatus.accepted:
        statusHindi = 'स्वीकृत';
        break;
      case LotStatus.picked:
        statusHindi = 'पिक किया गया';
        break;
      case LotStatus.delivered:
        statusHindi = 'डिलीवर किया गया';
        break;
      case LotStatus.completed:
        statusHindi = 'पूर्ण';
        break;
      case LotStatus.cancelled:
        statusHindi = 'रद्द';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materialTitle,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusHindi,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF147A65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    priceText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$weightText · $collectorInfo',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              if (locationText != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    isPickup
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isPickup ? 'पिकअप अनुरोध' : 'ड्रॉप-ऑफ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
