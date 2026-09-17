import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/lot_entity.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_state.dart';
import 'collector_dependency_container.dart';
import 'presentation/bloc/new_lot/new_lot_bloc.dart';
import 'presentation/bloc/new_lot/new_lot_event.dart';
import 'presentation/bloc/new_lot/new_lot_state.dart';

class NewScrapLotScreen extends StatelessWidget {
  const NewScrapLotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If a NewLotBloc is already provided above (e.g. in tests or parent scope), use it.
    // Otherwise provide a fresh instance using CollectorDependencyContainer.
    try {
      context.read<NewLotBloc>();
      return const _NewScrapLotView();
    } catch (_) {
      return BlocProvider<NewLotBloc>(
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
          return container.createNewLotBloc();
        },
        child: const _NewScrapLotView(),
      );
    }
  }
}

class _NewScrapLotView extends StatefulWidget {
  const _NewScrapLotView();

  @override
  State<_NewScrapLotView> createState() => _NewScrapLotViewState();
}

class _CategoryOption {
  final String label;
  final String value;
  final IconData icon;

  const _CategoryOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _NewScrapLotViewState extends State<_NewScrapLotView> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _weightController;

  static const List<_CategoryOption> _categories = [
    _CategoryOption(
      label: 'प्लास्टिक',
      value: 'Plastic',
      icon: Icons.recycling_rounded,
    ),
    _CategoryOption(
      label: 'ई-वेस्ट',
      value: 'E-Waste',
      icon: Icons.memory_rounded,
    ),
    _CategoryOption(
      label: 'धातु / लोहा',
      value: 'Metal',
      icon: Icons.construction_rounded,
    ),
    _CategoryOption(
      label: 'कागज़',
      value: 'Paper',
      icon: Icons.description_rounded,
    ),
    _CategoryOption(
      label: 'बैटरी',
      value: 'Battery',
      icon: Icons.battery_full_rounded,
    ),
    _CategoryOption(label: 'केबल', value: 'Cable', icon: Icons.cable_rounded),
    _CategoryOption(
      label: 'अन्य',
      value: 'Other',
      icon: Icons.category_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '1.0');
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  LotLocationEntity _resolveLocation(BuildContext context) {
    String? stateName;
    String? cityName;
    String? street;
    double? lat;
    double? lng;

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final address = authState.user.address;
        stateName = address?.state;
        cityName = address?.city;
        street = address?.street;
        lat = address?.latitude;
        lng = address?.longitude;
      }
    } catch (_) {}

    if (stateName == null ||
        stateName.isEmpty ||
        cityName == null ||
        cityName.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        stateName ??= args['state'] as String?;
        cityName ??= args['city'] as String?;
      }
    }

    final fullAddress =
        street ??
        ((cityName != null && stateName != null)
            ? '$cityName, $stateName'
            : null);

    return LotLocationEntity(
      address: fullAddress,
      state: stateName,
      city: cityName,
      pickupAddress: fullAddress,
      latitude: lat,
      longitude: lng,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final loc = _resolveLocation(context);
        context.read<NewLotBloc>().add(
          NewLotImageSelected(photo.path, state: loc.state, city: loc.city),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('फोटो चुनने में समस्या हुई: $e')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'फोटो का स्रोत चुनें',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191919),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF5EF),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF176B45),
                    ),
                  ),
                  title: const Text('कैमरा (Camera)'),
                  subtitle: const Text('सीधे कबाड़ की नई फोटो लें'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF5EF),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF176B45),
                    ),
                  ),
                  title: const Text('गैलरी (Gallery)'),
                  subtitle: const Text('फोन से पहले से मौजूद फोटो चुनें'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _adjustWeight(double delta) {
    final current = double.tryParse(_weightController.text.trim()) ?? 1.0;
    final updated = current + delta;
    if (updated <= 0) return;

    final formatted = updated == updated.roundToDouble()
        ? updated.toInt().toString()
        : updated.toStringAsFixed(1);

    _weightController.text = formatted;
    final loc = _resolveLocation(context);
    context.read<NewLotBloc>().add(
      NewLotWeightQuantityChanged(
        weightKg: updated,
        state: loc.state,
        city: loc.city,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewLotBloc, NewLotState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == NewLotStatus.failure &&
            state.errorMessage != null &&
            state.errorType == NewLotErrorType.submission) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        } else if (state.status == NewLotStatus.success &&
            state.createdLot != null) {
          Navigator.pushNamed(
            context,
            '/recyclers',
            arguments: state.createdLot!.id,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F8F5),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF191919),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'नया कबाड़ जोड़ें',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191919),
                  ),
                ),
                Text(
                  'फोटो लें और AI से कबाड़ की पहचान करें',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPhotoSection(state),
                        const SizedBox(height: 20),
                        _buildClassificationCard(state),
                        _buildCategorySelector(state),
                        const SizedBox(height: 24),
                        _buildWeightSection(state),
                        const SizedBox(height: 24),
                        _buildPriceCard(state),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSection(NewLotState state) {
    if (state.imagePath != null && state.imagePath!.isNotEmpty) {
      final file = File(state.imagePath!);
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Color(0xFF176B45),
              ),
              label: const Text(
                'फोटो बदलें',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF176B45),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 30,
              color: Color(0xFF176B45),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'कबाड़ की फोटो लें',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191919),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'साफ़ फोटो से AI बेहतर पहचान कर पाएगा',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('कैमरा'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF176B45),
                    side: const BorderSide(color: Color(0xFF176B45)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('गैलरी'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard(NewLotState state) {
    if (state.imagePath == null) return const SizedBox.shrink();

    if (state.status == NewLotStatus.classifying) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF176B45),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI पहचान रहा है...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF176B45),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'कबाड़ की सामग्री विश्लेषित की जा रही है',
                    style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == NewLotStatus.failure &&
        state.errorType == NewLotErrorType.classification) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFD97706),
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'पहचान नहीं हो सकी',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'आप नीचे कबाड़ का प्रकार खुद चुन सकते हैं।',
                    style: TextStyle(fontSize: 13, color: Color(0xFF78350F)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.classification != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5EF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB9DCC9)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0x26176B45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF176B45),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI से पहचान',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF176B45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.category ?? state.classification!.category,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF176B45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.classification!.confidencePercent.toInt()}% विश्वास',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategorySelector(NewLotState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'कबाड़ का प्रकार',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected =
                state.category != null &&
                (state.category!.toLowerCase() == cat.value.toLowerCase() ||
                    state.category!.toLowerCase() == cat.label.toLowerCase());

            return InkWell(
              onTap: () {
                final loc = _resolveLocation(context);
                context.read<NewLotBloc>().add(
                  NewLotCategoryChanged(
                    category: cat.value,
                    state: loc.state,
                    city: loc.city,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF176B45) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF176B45)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF555555),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF191919),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeightSection(NewLotState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'वज़न',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF176B45),
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: const Text(
                      'KG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF176B45),
                      ),
                    ),
                  ),
                ),
                onChanged: (val) {
                  final weight = double.tryParse(val.trim());
                  if (weight != null && weight > 0) {
                    final loc = _resolveLocation(context);
                    context.read<NewLotBloc>().add(
                      NewLotWeightQuantityChanged(
                        weightKg: weight,
                        state: loc.state,
                        city: loc.city,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickWeightButton('- 1 KG', () => _adjustWeight(-1)),
                    const SizedBox(width: 8),
                    _buildQuickWeightButton('+ 1 KG', () => _adjustWeight(1)),
                    const SizedBox(width: 8),
                    _buildQuickWeightButton('+ 5 KG', () => _adjustWeight(5)),
                    const SizedBox(width: 8),
                    _buildQuickWeightButton('+ 10 KG', () => _adjustWeight(10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickWeightButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(NewLotState state) {
    final hasPrice = state.priceEstimate != null;
    final isPricing = state.status == NewLotStatus.pricing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPrice ? const Color(0xFFEAF5EF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPrice ? const Color(0xFFB9DCC9) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'अनुमानित कीमत',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                ),
              ),
              if (hasPrice && state.priceEstimate!.recommendedRateInr > 0) ...[
                Builder(
                  builder: (context) {
                    final unit = state.priceEstimate!.unit;
                    final unitLabel = unit.toLowerCase().contains('piece')
                        ? 'Piece'
                        : 'KG';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF176B45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${state.priceEstimate!.recommendedRateInr.toStringAsFixed(0)} / $unitLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (isPricing)
            const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF176B45),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'कीमत का अनुमान लगाया जा रहा है...',
                  style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
              ],
            )
          else if (hasPrice) ...[
            Text(
              '₹${state.priceEstimate!.estimatedValueInr.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF176B45),
              ),
            ),
            if (state.priceEstimate!.estimatedValueMinInr > 0 &&
                state.priceEstimate!.estimatedValueMaxInr > 0) ...[
              const SizedBox(height: 4),
              Text(
                'रेंज: ₹${state.priceEstimate!.estimatedValueMinInr.toStringAsFixed(0)} - ₹${state.priceEstimate!.estimatedValueMaxInr.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ] else
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Color(0xFF888888),
                ),
                SizedBox(width: 8),
                Text(
                  'वज़न भरें और कीमत देखें',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(NewLotState state) {
    final isSubmitting = state.status == NewLotStatus.submitting;
    final hasImage = state.imagePath != null && state.imagePath!.isNotEmpty;
    final hasCategory = state.category != null && state.category!.isNotEmpty;
    final hasValidWeight = state.weightKg > 0;
    final isFormValid = hasImage && hasCategory && hasValidWeight;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: (isFormValid && !isSubmitting)
                ? () {
                    final loc = _resolveLocation(context);
                    context.read<NewLotBloc>().add(
                      NewLotSubmitted(
                        location: loc,
                        state: loc.state,
                        city: loc.city,
                      ),
                    );
                  }
                : null,
            icon: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search_rounded, size: 22),
            label: Text(
              isSubmitting ? 'जमा हो रहा है...' : 'रीसाइक्लर खोजें',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176B45),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
