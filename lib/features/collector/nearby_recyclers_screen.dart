import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/matched_recycler_entity.dart';
import 'collector_dependency_container.dart';
import 'presentation/bloc/matchmaking/matchmaking_bloc.dart';
import 'presentation/bloc/matchmaking/matchmaking_event.dart';
import 'presentation/bloc/matchmaking/matchmaking_state.dart';

class NearbyRecyclersScreen extends StatelessWidget {
  final String? lotId;

  const NearbyRecyclersScreen({super.key, this.lotId});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final effectiveLotId =
        lotId ??
        (args is String
            ? args
            : (args is Map ? args['lotId'] as String? : null));

    try {
      context.read<MatchmakingBloc>();
      return _NearbyRecyclersView(lotId: effectiveLotId);
    } catch (_) {
      return BlocProvider<MatchmakingBloc>(
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
          final bloc = container.createMatchmakingBloc();
          if (effectiveLotId != null && effectiveLotId.isNotEmpty) {
            bloc.add(FetchMatchedRecyclersEvent(effectiveLotId));
          }
          return bloc;
        },
        child: _NearbyRecyclersView(lotId: effectiveLotId),
      );
    }
  }
}

class _NearbyRecyclersView extends StatefulWidget {
  final String? lotId;

  const _NearbyRecyclersView({this.lotId});

  @override
  State<_NearbyRecyclersView> createState() => _NearbyRecyclersViewState();
}

class _NearbyRecyclersViewState extends State<_NearbyRecyclersView> {
  @override
  void initState() {
    super.initState();
    if (widget.lotId != null && widget.lotId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<MatchmakingBloc>();
          if (bloc.state is MatchmakingInitial) {
            bloc.add(FetchMatchedRecyclersEvent(widget.lotId!));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidLotId = widget.lotId != null && widget.lotId!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('पास के रीसाइक्लर'), centerTitle: true),
      body: SafeArea(
        child: !hasValidLotId
            ? _buildMissingLotIdState(context)
            : BlocBuilder<MatchmakingBloc, MatchmakingState>(
                builder: (context, state) {
                  if (state is MatchmakingLoading ||
                      state is MatchmakingInitial) {
                    return _buildLoadingState();
                  } else if (state is MatchmakingFailure) {
                    return _buildFailureState(context, state.message);
                  } else if (state is MatchmakingEmpty) {
                    return _buildEmptyState(context);
                  } else if (state is MatchmakingLoaded) {
                    return _buildLoadedState(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }

  Widget _buildMissingLotIdState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'लॉट आईडी नहीं मिली',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'रीसाइक्लर खोजने के लिए लॉट आईडी आवश्यक है। कृपया पहले लॉट बनाएं।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('वापस जाएं'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF176B45), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'रीसाइक्लर खोजे जा रहे हैं...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191919),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'आपके लॉट के लिए निकटतम और सबसे अच्छे रीसाइक्लर ढूंढे जा रहे हैं',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              'रीसाइक्लर लोड करने में समस्या',
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
                if (widget.lotId != null && widget.lotId!.isNotEmpty) {
                  context.read<MatchmakingBloc>().add(
                    FetchMatchedRecyclersEvent(widget.lotId!),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('पुनः प्रयास करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B45),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: Color(0xFF176B45),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'कोई रीसाइक्लर नहीं मिला',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'आपके क्षेत्र में फिलहाल कोई सक्रिय रीसाइक्लर उपलब्ध नहीं है। कृपया कुछ समय बाद पुनः प्रयास करें।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.lotId != null && widget.lotId!.isNotEmpty) {
                  context.read<MatchmakingBloc>().add(
                    FetchMatchedRecyclersEvent(widget.lotId!),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('पुनः प्रयास करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B45),
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

  Widget _buildLoadedState(BuildContext context, MatchmakingLoaded state) {
    final matches = state.matches;
    final selected = state.selectedRecycler;

    if (matches.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              const Text(
                'पास के रीसाइक्लर',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${matches.length} रीसाइक्लर आपके कबाड़ के लिए उपलब्ध हैं',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              ...matches.map((recycler) {
                final isSelected = selected?.recyclerId == recycler.recyclerId;
                final isBestMatch =
                    state.bestMatch?.recyclerId == recycler.recyclerId;
                return _buildRecyclerCard(
                  context: context,
                  recycler: recycler,
                  isSelected: isSelected,
                  isBestMatch: isBestMatch,
                );
              }),
            ],
          ),
        ),
        _buildBottomActionBar(context, state),
      ],
    );
  }

  Widget _buildRecyclerCard({
    required BuildContext context,
    required MatchedRecyclerEntity recycler,
    required bool isSelected,
    required bool isBestMatch,
  }) {
    final name =
        (recycler.recyclerName != null &&
            recycler.recyclerName!.trim().isNotEmpty)
        ? recycler.recyclerName!.trim()
        : 'अधिकृत रीसाइक्लर';

    final effectiveOffer = recycler.estimatedTotal > 0
        ? recycler.estimatedTotal
        : recycler.price;

    return GestureDetector(
      onTap: () {
        context.read<MatchmakingBloc>().add(SelectRecyclerEvent(recycler));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF176B45)
                : (isBestMatch
                      ? const Color(0xFFB9DCC9)
                      : const Color(0xFFE5E7EB)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x18176B45)
                  : const Color(0x0A000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isBestMatch || isSelected
                        ? const Color(0xFFEAF5EF)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.recycling,
                    color: isBestMatch || isSelected
                        ? const Color(0xFF176B45)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (recycler.address != null &&
                          recycler.address!.trim().isNotEmpty) ...[
                        Text(
                          recycler.address!.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recycler.distance > 0
                                ? '${recycler.distance.toStringAsFixed(1)} किमी दूर'
                                : 'पास में स्थित',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isBestMatch)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5EF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB9DCC9)),
                        ),
                        child: const Text(
                          'सर्वश्रेष्ठ मैच',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF176B45),
                          ),
                        ),
                      )
                    else if (recycler.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'मैच: ${(recycler.score * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'प्रस्तावित दर',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recycler.price > 0
                            ? '₹${recycler.price.toStringAsFixed(0)}'
                            : 'पूछताछ करें',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF191919),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'अनुमानित ऑफर',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${effectiveOffer.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF176B45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isSelected
                  ? OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color(0xFF176B45),
                      ),
                      label: const Text(
                        'चयनित',
                        style: TextStyle(
                          color: Color(0xFF176B45),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF176B45),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        context.read<MatchmakingBloc>().add(
                          SelectRecyclerEvent(recycler),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176B45),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('रीसाइक्लर चुनें'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, MatchmakingLoaded state) {
    final selected = state.selectedRecycler;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x14000000),
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: selected == null
                ? null
                : () {
                    final effectiveOffer = selected.estimatedTotal > 0
                        ? selected.estimatedTotal
                        : selected.price;
                    Navigator.pushNamed(
                      context,
                      '/accept-offer',
                      arguments: {
                        'recyclerName':
                            selected.recyclerName ?? 'अधिकृत रीसाइक्लर',
                        'offerPrice': effectiveOffer,
                        'pickup': true,
                        'lotId': state.lotId,
                        'recyclerId': selected.recyclerId,
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176B45),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selected != null
                  ? 'ऑफर की पुष्टि करें (${selected.recyclerName ?? 'रीसाइक्लर'})'
                  : 'कोई रीसाइक्लर चुनें',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
