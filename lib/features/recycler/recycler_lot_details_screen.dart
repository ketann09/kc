import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/language_audio_sheet.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../../domain/entities/lot_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_state.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_bloc.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_event.dart';
import 'presentation/bloc/lot_details/recycler_lot_details_state.dart';
import 'recycler_dependency_container.dart';

class RecyclerLotDetailsScreen extends StatelessWidget {
  final String lotId;

  const RecyclerLotDetailsScreen({super.key, required this.lotId});

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
          final container = RecyclerDependencyContainer.fromApiClient(
            apiClient,
          );
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
  final TextEditingController _actualWeightController = TextEditingController();
  String? _actualWeightError;

  @override
  void dispose() {
    _actualWeightController.dispose();
    super.dispose();
  }

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
        title: Text(
          context.l10n.lotDetails,
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
                  const Icon(Icons.language, size: 15, color: Color(0xFF2E7D32)),
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
          BlocBuilder<RecyclerLotDetailsBloc, RecyclerLotDetailsState>(
            builder: (context, state) {
              if (state is RecyclerLotDetailsLoaded) {
                final l10n = context.l10n;
                final lot = state.lot;
                return SpeakerButton(
                  textToSpeak:
                      '${l10n.lotDetails}. ${lot.materialName ?? lot.description ?? ""}. ${l10n.weight}: ${lot.actualWeight ?? lot.estimatedWeight} kg. ${l10n.settlementAmount}: ₹${(lot.finalPrice ?? lot.estimatedPrice).toStringAsFixed(0)}.',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RecyclerLotDetailsBloc, RecyclerLotDetailsState>(
          listener: (context, state) {
            if (state is RecyclerLotDetailsLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionSuccessMessage!),
                    backgroundColor: const Color(0xFF1B5E20),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state.actionErrorMessage != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          CircularProgressIndicator(color: Color(0xFF147A65), strokeWidth: 3),
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

  Widget _buildLoadedState(
    BuildContext context,
    RecyclerLotDetailsLoaded state,
  ) {
    final lot = state.lot;
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

    final isCompleted = lot.status == LotStatus.completed;
    final weight = lot.actualWeight ?? lot.estimatedWeight;
    final weightText = weight >= 1.0
        ? '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} किलो'
        : '${(weight * 1000).toStringAsFixed(0)} ग्राम';

    final displayPrice = lot.finalPrice ?? lot.estimatedPrice;
    final priceText = displayPrice > 0
        ? '₹${displayPrice.toStringAsFixed(0)}'
        : 'मूल्य प्रतीक्षित';

    final priceLabel = isCompleted ? 'अंतिम मूल्य' : 'अनुमानित मूल्य';
    final weightLabel = (isCompleted || lot.actualWeight != null)
        ? (context.isMarathi ? 'प्रत्यक्ष वजन' : 'वास्तविक वजन')
        : (context.isMarathi ? 'एकूण वजन' : 'कुल वजन');

    final isPickup = lot.schedulePickup != null;

    final l10n = context.l10n;
    String statusHindi;
    Color statusColor;
    Color statusBgColor;
    switch (lot.status) {
      case LotStatus.pending:
        statusHindi = l10n.statusPending;
        statusColor = const Color(0xFFF57C00);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case LotStatus.accepted:
        statusHindi = l10n.statusAccepted;
        statusColor = const Color(0xFF1B5E20);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case LotStatus.picked:
        statusHindi = l10n.statusPicked;
        statusColor = const Color(0xFF0288D1);
        statusBgColor = const Color(0xFFE1F5FE);
        break;
      case LotStatus.delivered:
        statusHindi = l10n.statusDelivered;
        statusColor = const Color(0xFF7B1FA2);
        statusBgColor = const Color(0xFFF3E5F5);
        break;
      case LotStatus.completed:
        statusHindi = l10n.statusCompletedDetailed;
        statusColor = const Color(0xFF2E7D32);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case LotStatus.cancelled:
        statusHindi = l10n.statusCancelled;
        statusColor = const Color(0xFFC62828);
        statusBgColor = const Color(0xFFFFEBEE);
        break;
    }

    String? dateText;
    if (lot.createdAt != null) {
      final d = lot.createdAt!;
      dateText = '${d.day}/${d.month}/${d.year}';
    }

    final locationText =
        (lot.location.city != null && lot.location.city!.isNotEmpty)
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
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusHindi,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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
                        Text(
                          priceLabel,
                          style: const TextStyle(
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
                  Container(width: 1, height: 48, color: Colors.grey.shade200),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weightLabel,
                          style: const TextStyle(
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
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final imgUrl = lot.images[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imgUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
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

          // 6. Real Lot Lifecycle Section
          _buildLifecycleSection(context, state, lot),
        ],
      ),
    );
  }

  Widget _buildLifecycleSection(
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else if (lot.status == LotStatus.accepted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                    Icon(Icons.verified, color: Color(0xFF1B5E20), size: 22),
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: state.isUpdatingLifecycle
                  ? null
                  : () => _showPickupConfirmationDialog(context, lot),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF90CAF9),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              icon: state.isUpdatingLifecycle
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.local_shipping_outlined, size: 22),
              label: Text(
                state.isUpdatingLifecycle
                    ? 'अपडेट किया जा रहा है...'
                    : 'पिकअप के लिए चिह्नित करें',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (lot.status == LotStatus.picked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF81D4FA)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Color(0xFF0277BD),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'लॉट पारगमन में है',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'लॉट को पिक कर लिया गया है और यह रीसाइक्लर केंद्र के रास्ते में है।',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF01579B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: state.isUpdatingLifecycle
                  ? null
                  : () => _showDeliveryConfirmationDialog(context, lot),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCE93D8),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              icon: state.isUpdatingLifecycle
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.inventory_2_outlined, size: 22),
              label: Text(
                state.isUpdatingLifecycle
                    ? 'अपडेट किया जा रहा है...'
                    : 'डिलीवर के लिए चिह्नित करें',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (lot.status == LotStatus.delivered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCE93D8)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Color(0xFF6A1B9A), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'लॉट डिलीवर हो चुका है',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'लॉट केंद्र पर प्राप्त हो गया है। कृपया अंतिम सत्यापन के लिए वास्तविक वजन दर्ज करें।',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A148C),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'सत्यापन एवं समापन',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _actualWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'वास्तविक वजन (KG)',
                      hintText: 'उदा. 25.5',
                      prefixIcon: const Icon(Icons.scale_outlined),
                      errorText: _actualWeightError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) {
                      if (_actualWeightError != null) {
                        setState(() {
                          _actualWeightError = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: state.isUpdatingLifecycle
                  ? null
                  : () => _handleCompleteLot(context, lot),
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
              icon: state.isUpdatingLifecycle
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.task_alt, size: 22),
              label: Text(
                state.isUpdatingLifecycle
                    ? 'पूर्ण किया जा रहा है...'
                    : 'लॉट पूरा करें',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (lot.status == LotStatus.completed) {
      final weight = lot.actualWeight ?? lot.estimatedWeight;
      final weightText = weight >= 1.0
          ? '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} किलो'
          : '${(weight * 1000).toStringAsFixed(0)} ग्राम';
      final displayPrice = lot.finalPrice ?? lot.estimatedPrice;
      final priceText = displayPrice > 0
          ? '₹${displayPrice.toStringAsFixed(0)}'
          : 'मूल्य प्रतीक्षित';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
                Icon(Icons.check_circle, color: Color(0xFF1B5E20), size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'लॉट सफलतापूर्वक पूरा हो गया',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFA5D6A7)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'सत्यापित वास्तविक वजन:',
                  style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
                ),
                Text(
                  weightText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'अंतिम मूल्य:',
                  style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
                ),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                key: const Key('create_or_view_transaction_button'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/transaction-details',
                    arguments: {
                      'lotId': lot.id,
                      'lot': lot,
                      'isRecycler': true,
                    },
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'लेन-देन विवरण / प्रबंधन',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      String statusHindi;
      switch (lot.status) {
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
            child: const Text(
              'रद्द करें',
              style: TextStyle(color: Colors.grey),
            ),
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

  Future<void> _showPickupConfirmationDialog(
    BuildContext context,
    LotEntity lot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'पिकअप की पुष्टि',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'क्या आप इस लॉट को पिकअप के लिए चिह्नित करना चाहते हैं?',
          style: TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'रद्द करें',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('पुष्टि करें'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecyclerLotDetailsBloc>().add(
        UpdateRecyclerLotLifecycleEvent(lotId: lot.id, status: 'picked'),
      );
    }
  }

  Future<void> _showDeliveryConfirmationDialog(
    BuildContext context,
    LotEntity lot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFF6A1B9A)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'डिलीवरी की पुष्टि',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'क्या आप पुष्टि करते हैं कि लॉट रीसाइक्लर केंद्र पर डिलीवर हो चुका है?',
          style: TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'रद्द करें',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('पुष्टि करें'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecyclerLotDetailsBloc>().add(
        UpdateRecyclerLotLifecycleEvent(lotId: lot.id, status: 'delivered'),
      );
    }
  }

  Future<void> _handleCompleteLot(BuildContext context, LotEntity lot) async {
    final text = _actualWeightController.text.trim();
    final weight = double.tryParse(text);

    if (weight == null || weight <= 0 || weight.isNaN || weight.isInfinite) {
      setState(() {
        _actualWeightError = 'कृपया वैध वास्तविक वजन (किलो) दर्ज करें';
      });
      return;
    }

    setState(() {
      _actualWeightError = null;
    });

    final finalPrice = lot.finalPrice ?? lot.estimatedPrice;
    final priceStr = finalPrice > 0
        ? '₹${finalPrice.toStringAsFixed(0)}'
        : 'अनिर्धारित';
    final weightStr = '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} किलो';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.task_alt, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'लॉट समापन की पुष्टि',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'क्या आप इस लॉट को वास्तविक वजन $weightStr एवं अंतिम मूल्य $priceStr पर पूरा करना चाहते हैं?',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'रद्द करें',
              style: TextStyle(color: Colors.grey),
            ),
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
            child: const Text('पूरा करें'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecyclerLotDetailsBloc>().add(
        UpdateRecyclerLotLifecycleEvent(
          lotId: lot.id,
          status: 'completed',
          actualWeight: weight,
          finalPrice: finalPrice,
        ),
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}
