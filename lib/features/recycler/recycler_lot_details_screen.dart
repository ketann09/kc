import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/lot_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_state.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_event.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_state.dart';
import 'recycler_dependency_container.dart';

class RecyclerLotDetailsScreen extends StatelessWidget {
  final String lotId;

  const RecyclerLotDetailsScreen({
    super.key,
    required this.lotId,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RecyclerLotDetailsBloc>();
      return _RecyclerLotDetailsView(lotId: lotId);
    } catch (_) {
      return BlocProvider<RecyclerLotDetailsBloc>(
        create: (ctx) {
          ApiClient apiClient;
          try {
            apiClient = ctx.read<ApiClient>();
          } catch (_) {
            apiClient = ApiClient();
          }
          final container =
              RecyclerDependencyContainer.fromApiClient(apiClient);
          final bloc = container.createRecyclerLotDetailsBloc();

          bool isAuthenticated = true;
          try {
            final authBloc = ctx.read<AuthBloc>();
            if (authBloc.state is! Authenticated) {
              isAuthenticated = false;
            }
          } catch (_) {}

          if (isAuthenticated && lotId.isNotEmpty) {
            bloc.add(FetchRecyclerLotDetailsEvent(lotId));
          }
          return bloc;
        },
        child: _RecyclerLotDetailsView(lotId: lotId),
      );
    }
  }
}

class _RecyclerLotDetailsView extends StatefulWidget {
  final String lotId;

  const _RecyclerLotDetailsView({required this.lotId});

  @override
  State<_RecyclerLotDetailsView> createState() =>
      _RecyclerLotDetailsViewState();
}

class _RecyclerLotDetailsViewState extends State<_RecyclerLotDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.lotId.isNotEmpty) {
        final bloc = context.read<RecyclerLotDetailsBloc>();
        if (bloc.state is RecyclerLotDetailsInitial) {
          bool isAuthenticated = true;
          try {
            final authBloc = context.read<AuthBloc>();
            if (authBloc.state is! Authenticated) {
              isAuthenticated = false;
            }
          } catch (_) {}

          if (isAuthenticated) {
            bloc.add(FetchRecyclerLotDetailsEvent(widget.lotId));
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
          'लॉट विवरण',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<RecyclerLotDetailsBloc, RecyclerLotDetailsState>(
          listener: (context, state) {
            if (state is RecyclerLotDetailsLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionSuccessMessage!),
                    backgroundColor: const Color(0xFF1B5E20),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state.actionErrorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionErrorMessage!),
                    backgroundColor: const Color(0xFFD32F2F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is RecyclerLotDetailsLoading ||
                state is RecyclerLotDetailsInitial) {
              return _buildLoadingState();
            } else if (state is RecyclerLotDetailsFailure) {
              return _buildFailureState(context, state.message);
            } else if (state is RecyclerLotDetailsLoaded) {
              return _buildLoadedState(context, state);
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
          CircularProgressIndicator(
            color: Color(0xFF147A65),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'लॉट विवरण लोड हो रहा है...',
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
              'विवरण लोड करने में समस्या',
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
                context.read<RecyclerLotDetailsBloc>().add(
                      RetryRecyclerLotDetailsEvent(widget.lotId),
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

  Widget _buildLoadedState(BuildContext context, RecyclerLotDetailsLoaded state) {
    final lot = state.lot;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final materialTitle = (lot.materialName != null &&
            lot.materialName!.isNotEmpty)
        ? lot.materialName!
        : (lot.mlPrediction?.predictedCategory != null &&
                lot.mlPrediction!.predictedCategory!.isNotEmpty)
            ? lot.mlPrediction!.predictedCategory!
            : (lot.description != null && lot.description!.isNotEmpty)
                ? lot.description!
                : 'स्क्रैप लॉट';

    final weight = lot.actualWeight ?? lot.estimatedWeight;
    final weightText = weight >= 1.0
        ? '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} किलो'
        : '${(weight * 1000).toStringAsFixed(0)} ग्राम';

    final priceText = lot.estimatedPrice > 0
        ? '₹${lot.estimatedPrice.toStringAsFixed(0)}'
        : 'मूल्य प्रतीक्षित';

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

    String? dateText;
    if (lot.createdAt != null) {
      final d = lot.createdAt!;
      dateText = '${d.day}/${d.month}/${d.year}';
    }

    final locationText = (lot.location.city != null &&
            lot.location.city!.isNotEmpty)
        ? (lot.location.state != null && lot.location.state!.isNotEmpty
            ? '${lot.location.city}, ${lot.location.state}'
            : lot.location.city!)
        : (lot.location.address != null && lot.location.address!.isNotEmpty
            ? lot.location.address!
            : null);

    return RefreshIndicator(
      color: const Color(0xFF147A65),
      onRefresh: () async {
        context.read<RecyclerLotDetailsBloc>().add(
              FetchRecyclerLotDetailsEvent(widget.lotId),
            );
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // 1. Material / Category Header
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
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'लॉट #${lot.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusHindi,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF147A65),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Price + Weight Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'अनुमानित मूल्य',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'कुल वजन',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weightText,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Lot Information Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'लॉट की जानकारी',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'कलेक्टर',
                    value: lot.collectorName ?? 'कलेक्टर',
                  ),
                  if (lot.collectorPhone != null &&
                      lot.collectorPhone!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'फोन नंबर',
                      value: lot.collectorPhone!,
                    ),
                  ],
                  if (dateText != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'बनाने की तारीख',
                      value: dateText,
                    ),
                  ],
                  if (lot.mlPrediction?.confidenceScore != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.auto_awesome_outlined,
                      label: 'AI वर्गीकरण सटीकता',
                      value:
                          '${(lot.mlPrediction!.confidenceScore! * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Location & Handover Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'स्थान एवं हैंडओवर',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: isPickup
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    label: 'हैंडओवर प्रकार',
                    value: isPickup
                        ? 'पिकअप अनुरोध'
                        : 'रीसाइक्लर केंद्र पर ड्रॉप-ऑफ',
                  ),
                  if (locationText != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'पता',
                      value: locationText,
                    ),
                  ],
                  if (lot.location.address != null &&
                      lot.location.address!.isNotEmpty &&
                      locationText != lot.location.address) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'विस्तृत पता',
                      value: lot.location.address!,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 5. Description & Images (if present)
          if (lot.description != null && lot.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'विवरण',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lot.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (lot.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'फोटो',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: lot.images.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final imgUrl = lot.images[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imgUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 6. Real Lot Acceptance CTA / Status Section
          _buildAcceptanceSection(context, state, lot),
        ],
      ),
    );
  }

  Widget _buildAcceptanceSection(
    BuildContext context,
    RecyclerLotDetailsLoaded state,
    LotEntity lot,
  ) {
    if (lot.status == LotStatus.pending) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: state.isAccepting
              ? null
              : () => _showAcceptConfirmationDialog(context, lot),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF81C784),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
          ),
          icon: state.isAccepting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle_outline, size: 22),
          label: Text(
            state.isAccepting
                ? 'लॉट स्वीकार किया जा रहा है...'
                : 'लॉट स्वीकार करें',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } else if (lot.status == LotStatus.accepted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Color(0xFF1B5E20),
                  size: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'यह लॉट आपके द्वारा स्वीकार किया गया है',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'कलेक्टर से संपर्क कर लॉट का पिकअप या डिलीवरी सुनिश्चित करें।',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7D32),
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    } else {
      String statusHindi;
      switch (lot.status) {
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
        default:
          statusHindi = lot.status.value;
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'लॉट की स्थिति: $statusHindi',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showAcceptConfirmationDialog(
    BuildContext context,
    LotEntity lot,
  ) async {
    final priceStr = lot.estimatedPrice > 0
        ? '₹${lot.estimatedPrice.toStringAsFixed(0)}'
        : 'अनुमानित दर';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'लॉट स्वीकृति की पुष्टि',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'क्या आप इस लॉट को प्रदर्शित अनुमानित मूल्य $priceStr पर स्वीकार करना चाहते हैं?',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('रद्द करें', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('स्वीकार करें'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecyclerLotDetailsBloc>().add(
            AcceptRecyclerLotEvent(lotId: lot.id),
          );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
