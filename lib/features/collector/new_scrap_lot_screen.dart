import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/language_audio_sheet.dart';
import '../../core/widgets/offline_blocked_sheet.dart';
import '../../core/widgets/speaker_button.dart';
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
  final String labelKey;
  final String value;
  final IconData icon;

  const _CategoryOption({
    required this.labelKey,
    required this.value,
    required this.icon,
  });
}

class _NewScrapLotViewState extends State<_NewScrapLotView> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _weightController;

  static const List<_CategoryOption> _categories = [
    _CategoryOption(
      labelKey: 'plastic',
      value: 'Plastic',
      icon: Icons.recycling_rounded,
    ),
    _CategoryOption(
      labelKey: 'pcb',
      value: 'E-Waste',
      icon: Icons.memory_rounded,
    ),
    _CategoryOption(labelKey: 'crt', value: 'CRT', icon: Icons.tv_rounded),
    _CategoryOption(
      labelKey: 'lcd_led',
      value: 'LCD_LED',
      icon: Icons.monitor_rounded,
    ),
    _CategoryOption(
      labelKey: 'cable',
      value: 'Cable',
      icon: Icons.cable_rounded,
    ),
    _CategoryOption(
      labelKey: 'battery',
      value: 'Battery',
      icon: Icons.battery_full_rounded,
    ),
    _CategoryOption(
      labelKey: 'motors',
      value: 'Motors',
      icon: Icons.settings_suggest_rounded,
    ),
    _CategoryOption(
      labelKey: 'metal',
      value: 'Metal',
      icon: Icons.construction_rounded,
    ),
    _CategoryOption(
      labelKey: 'paper',
      value: 'Paper',
      icon: Icons.description_rounded,
    ),
    _CategoryOption(
      labelKey: 'other',
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

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      stateName ??= args['state'] as String?;
      cityName ??= args['city'] as String?;
      street ??= args['street'] as String? ?? args['address'] as String?;
      lat ??= (args['latitude'] as num?)?.toDouble();
      lng ??= (args['longitude'] as num?)?.toDouble();
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
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
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
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    context.isMarathi
                        ? 'फोटोचा स्रोत निवडा'
                        : context.isEnglish
                        ? 'Select Photo Source'
                        : 'फोटो का स्रोत चुनें',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.saffron50,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.saffronPrimary,
                    ),
                  ),
                  title: Text(l10n.camera),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.saffron50,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.saffronPrimary,
                    ),
                  ),
                  title: Text(l10n.gallery),
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

  bool _isPieceBased(NewLotState state) {
    final cat = (state.category ?? '').toLowerCase();
    final unit = (state.priceEstimate?.unit ?? '').toLowerCase();
    return cat.contains('crt') || unit.contains('piece');
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
        quantity: 1,
        state: loc.state,
        city: loc.city,
      ),
    );
  }

  void _adjustQuantity(int delta) {
    final current = int.tryParse(_weightController.text.trim()) ?? 1;
    final updated = current + delta;
    if (updated <= 0) return;

    _weightController.text = updated.toString();
    final loc = _resolveLocation(context);
    context.read<NewLotBloc>().add(
      NewLotWeightQuantityChanged(
        weightKg: updated.toDouble(),
        quantity: updated,
        state: loc.state,
        city: loc.city,
      ),
    );
  }

  String _getCategoryDisplay(String key) {
    final l10n = context.l10n;
    switch (key) {
      case 'plastic':
        return l10n.categoryPlastic;
      case 'pcb':
        return l10n.categoryEwaste;
      case 'crt':
        return l10n.categoryCrt;
      case 'lcd_led':
        return l10n.categoryLcdLed;
      case 'cable':
        return l10n.categoryCable;
      case 'battery':
        return l10n.categoryBattery;
      case 'motors':
        return l10n.categoryMotors;
      case 'metal':
        return l10n.categoryMetal;
      case 'paper':
        return l10n.categoryPaper;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }

  int _resolveCurrentStep(NewLotState state) {
    if (state.category == null || state.category!.isEmpty) {
      return 1;
    }
    if (state.priceEstimate == null) {
      return 2;
    }
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<NewLotBloc, NewLotState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.category != current.category ||
          previous.quantity != current.quantity ||
          previous.weightKg != current.weightKg,
      listener: (context, state) {
        if (_isPieceBased(state)) {
          final expected = state.quantity.toString();
          if (_weightController.text != expected) {
            _weightController.text = expected;
          }
        }
        if (state.status == NewLotStatus.failure &&
            state.errorMessage != null &&
            state.errorType == NewLotErrorType.submission) {
          ConnectivityService? connectivity;
          try {
            connectivity = context.read<ConnectivityService>();
          } catch (_) {
            connectivity = null;
          }

          final isOffline =
              (connectivity != null && !connectivity.isOnline) ||
              (state.lastException != null &&
                  (state.lastException!.isNetworkError ||
                      state.lastException!.isTimeout));

          if (isOffline) {
            OfflineBlockedSheet.show(
              context,
              action: OfflineBlockedAction.createLot,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
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
        if (_isPieceBased(state) && _weightController.text.contains('.')) {
          _weightController.text = state.quantity.toString();
        }
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.pageBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.dark900,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createNewLot,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark900,
                  ),
                ),
                Text(
                  l10n.takePhotoAi,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dark500,
                  ),
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () => LanguageAudioSheet.show(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.saffron50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.saffronPrimary.withValues(alpha: 0.35),
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
              SpeakerButton(
                textToSpeak:
                    '${l10n.createNewLot}. ${l10n.takeScrapPhoto}. ${l10n.weight}. ${l10n.estimatedPrice}.',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Stepper
                        AppStepper(
                          currentStep: _resolveCurrentStep(state),
                          steps: [
                            AppStepItem(
                              number: 1,
                              title: context.isMarathi
                                  ? 'सामग्री'
                                  : context.isEnglish
                                  ? 'Material'
                                  : 'सामग्री',
                            ),
                            AppStepItem(
                              number: 2,
                              title: context.isMarathi
                                  ? 'प्रमाण'
                                  : context.isEnglish
                                  ? 'Quantity'
                                  : 'मात्रा',
                            ),
                            AppStepItem(
                              number: 3,
                              title: context.isMarathi
                                  ? 'पुनरावलोकन'
                                  : context.isEnglish
                                  ? 'Review'
                                  : 'समीक्षा',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
    final l10n = context.l10n;

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
              border: Border.all(color: AppColors.saffron200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
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
                color: AppColors.saffronPrimary,
              ),
              label: Text(
                l10n.changePhoto,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saffronPrimary,
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
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.saffron50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 30,
              color: AppColors.saffronPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.takeScrapPhoto,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.takeScrapPhotoSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.dark500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: Text(l10n.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.saffronPrimary,
                    side: const BorderSide(
                      color: AppColors.saffronPrimary,
                      width: 1.5,
                    ),
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
                  label: Text(l10n.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark900,
                    side: const BorderSide(color: AppColors.border),
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
    final l10n = context.l10n;

    if (state.imagePath == null) return const SizedBox.shrink();

    if (state.status == NewLotStatus.classifying) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.saffron50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.saffron200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.saffronPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiClassifying,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.saffronDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.isMarathi
                        ? 'कबाडी सामग्रीचे विश्लेषण सुरू आहे'
                        : 'कबाड़ की सामग्री विश्लेषित की जा रही है',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.saffronDark,
                    ),
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
      final canRetry = state.imagePath != null && state.imagePath!.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.amberPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aiFailed,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.isMarathi
                            ? 'तुम्ही खाली स्क्रॅपचा प्रकार स्वतः निवडू शकता किंवा पुन्हा स्कॅन करू शकता.'
                            : 'आप नीचे कबाड़ का प्रकार खुद चुन सकते हैं या दोबारा स्कैन कर सकते हैं।',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canRetry) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('retry_ai_scan_button'),
                  onPressed: () {
                    final loc = _resolveLocation(context);
                    context.read<NewLotBloc>().add(
                      NewLotImageSelected(
                        state.imagePath!,
                        state: loc.state,
                        city: loc.city,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(l10n.retryAiScan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffronPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (state.category == null) return const SizedBox.shrink();

    final isAi = state.classification != null && !state.isManualCategory;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.saffron50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.saffron200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.saffronPrimary.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(
              isAi ? Icons.auto_awesome : Icons.check_circle_outline_rounded,
              color: AppColors.saffronPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAi ? l10n.aiIdentified : l10n.selectedCategoryLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffronDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.category ?? state.classification?.category ?? '',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark900,
                  ),
                ),
              ],
            ),
          ),
          if (isAi && state.classification != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.saffronPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.classification!.confidencePercent.toInt()}% ${l10n.confidence}',
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

  Widget _buildCategorySelector(NewLotState state) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scrapType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dark900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final categoryDisplay = _getCategoryDisplay(cat.labelKey);
            final isSelected =
                state.category != null &&
                (state.category!.toLowerCase() == cat.value.toLowerCase() ||
                    state.category!.toLowerCase() ==
                        cat.labelKey.toLowerCase() ||
                    (cat.value == 'LCD_LED' &&
                        state.category!.toLowerCase().contains('lcd')) ||
                    (cat.value == 'E-Waste' &&
                        (state.category!.toLowerCase().contains('pcb') ||
                            state.category!.toLowerCase().contains('ewaste') ||
                            state.category!.toLowerCase().contains(
                              'e-waste',
                            ))) ||
                    state.category!.toLowerCase() ==
                        categoryDisplay.toLowerCase());

            return InkWell(
              onTap: () {
                final loc = _resolveLocation(context);
                if (isSelected) {
                  context.read<NewLotBloc>().add(
                    NewLotCategoryChanged(
                      category: null,
                      isManual: false,
                      state: loc.state,
                      city: loc.city,
                    ),
                  );
                } else {
                  context.read<NewLotBloc>().add(
                    NewLotCategoryChanged(
                      category: cat.value,
                      isManual: true,
                      state: loc.state,
                      city: loc.city,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.saffronPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.saffronPrimary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.saffronPrimary.withValues(
                              alpha: 0.25,
                            ),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.dark500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryDisplay,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.dark900,
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
    final l10n = context.l10n;
    final isPiece = _isPieceBased(state);
    final unitLabel = isPiece ? l10n.pieceUnit : 'KG';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weight,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dark900,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _weightController,
                keyboardType: isPiece
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark900,
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
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.saffronPrimary,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Text(
                      unitLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.saffronPrimary,
                      ),
                    ),
                  ),
                ),
                onChanged: (val) {
                  final loc = _resolveLocation(context);
                  if (isPiece) {
                    final qty = int.tryParse(val.trim());
                    if (qty != null && qty > 0) {
                      context.read<NewLotBloc>().add(
                        NewLotWeightQuantityChanged(
                          weightKg: qty.toDouble(),
                          quantity: qty,
                          state: loc.state,
                          city: loc.city,
                        ),
                      );
                    }
                  } else {
                    final weight = double.tryParse(val.trim());
                    if (weight != null && weight > 0) {
                      context.read<NewLotBloc>().add(
                        NewLotWeightQuantityChanged(
                          weightKg: weight,
                          quantity: 1,
                          state: loc.state,
                          city: loc.city,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: isPiece
                      ? [
                          _buildQuickWeightButton(
                            '- 1 Piece',
                            () => _adjustQuantity(-1),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 1 Piece',
                            () => _adjustQuantity(1),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 2 Pieces',
                            () => _adjustQuantity(2),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 5 Pieces',
                            () => _adjustQuantity(5),
                          ),
                        ]
                      : [
                          _buildQuickWeightButton(
                            '- 1 KG',
                            () => _adjustWeight(-1),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 1 KG',
                            () => _adjustWeight(1),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 5 KG',
                            () => _adjustWeight(5),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickWeightButton(
                            '+ 10 KG',
                            () => _adjustWeight(10),
                          ),
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
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.dark900,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(NewLotState state) {
    final l10n = context.l10n;
    final hasPrice = state.priceEstimate != null;
    final isPricing = state.status == NewLotStatus.pricing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPrice ? AppColors.saffron50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPrice ? AppColors.saffron200 : AppColors.border,
          width: hasPrice ? 1.5 : 1,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.estimatedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark900,
                ),
              ),
              if (hasPrice && state.priceEstimate!.recommendedRateInr > 0) ...[
                Builder(
                  builder: (context) {
                    final isPiece = _isPieceBased(state);
                    final unit = state.priceEstimate!.unit;
                    final unitLabel =
                        (isPiece || unit.toLowerCase().contains('piece'))
                        ? l10n.pieceUnit
                        : 'KG';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.saffronPrimary,
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
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.saffronPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  context.isMarathi
                      ? 'किंमत काढली जात आहे...'
                      : 'कीमत का अनुमान लगाया जा रहा है...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.dark500,
                  ),
                ),
              ],
            )
          else if (hasPrice) ...[
            Row(
              children: [
                Text(
                  '₹${state.priceEstimate!.estimatedValueInr.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.saffronPrimary,
                  ),
                ),
                const Spacer(),
                SpeakerButton(
                  textToSpeak:
                      '${l10n.estimatedPrice}: ₹${state.priceEstimate!.estimatedValueInr.toStringAsFixed(0)}',
                ),
              ],
            ),
            if (state.priceEstimate!.estimatedValueMinInr > 0 &&
                state.priceEstimate!.estimatedValueMaxInr > 0) ...[
              const SizedBox(height: 4),
              Text(
                'रेंज: ₹${state.priceEstimate!.estimatedValueMinInr.toStringAsFixed(0)} - ₹${state.priceEstimate!.estimatedValueMaxInr.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark500,
                ),
              ),
            ],
          ] else
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.dark400,
                ),
                const SizedBox(width: 8),
                Text(
                  context.isMarathi
                      ? 'वजन भरा आणि किंमत पहा'
                      : 'वज़न भरें और कीमत देखें',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(NewLotState state) {
    final l10n = context.l10n;
    final isSubmitting = state.status == NewLotStatus.submitting;
    final hasImage = state.imagePath != null && state.imagePath!.isNotEmpty;
    final hasCategory = state.category != null && state.category!.isNotEmpty;
    final isPiece = _isPieceBased(state);
    final hasValidQuantity = isPiece
        ? state.quantity >= 1
        : state.weightKg >= 0.1;
    final isFormValid = hasCategory && hasValidQuantity;
    final finalEnabled = isFormValid && !isSubmitting;
    final loc = _resolveLocation(context);

    debugPrint(
      'NEW LOT CTA DEBUG: '
      'status=${state.status}, '
      'category=${state.category}, '
      'quantity=${state.quantity}, '
      'weightKg=${state.weightKg}, '
      'priceEstimate=${state.priceEstimate}, '
      'state=${loc.state}, '
      'city=${loc.city}, '
      'imagePath=${state.imagePath}',
    );

    debugPrint(
      'CTA CONDITIONS: '
      'categoryValid=$hasCategory, '
      'quantityValid=$hasValidQuantity, '
      'locationValid=true, '
      'priceValid=${state.priceEstimate != null}, '
      'imageValid=$hasImage, '
      'isSubmitting=$isSubmitting, '
      'finalEnabled=$finalEnabled',
    );

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
            onPressed: finalEnabled
                ? () {
                    ConnectivityService? connectivity;
                    try {
                      connectivity = context.read<ConnectivityService>();
                    } catch (_) {
                      connectivity = null;
                    }

                    if (connectivity != null && !connectivity.isOnline) {
                      OfflineBlockedSheet.show(
                        context,
                        action: OfflineBlockedAction.createLot,
                      );
                      return;
                    }

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
              isSubmitting
                  ? (context.isMarathi ? 'जमा होत आहे...' : 'जमा हो रहा है...')
                  : l10n.findRecyclers,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffronPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              elevation: 1,
              shadowColor: AppColors.saffronPrimary.withValues(alpha: 0.3),
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
