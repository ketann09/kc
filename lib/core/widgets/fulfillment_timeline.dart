import 'package:flutter/material.dart';

import '../../domain/entities/lot_entity.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

/// Represents a single stage in [FulfillmentTimeline].
class TimelineStage {
  final String title;
  final String description;

  const TimelineStage({required this.title, required this.description});
}

/// A vertical lifecycle fulfillment timeline matching prototype `PickupTimeline.tsx`.
/// Clearly depicts "what has happened" and "what happens next" with vernacular
/// titles and intuitive checkmark / clock status indicators.
class FulfillmentTimeline extends StatelessWidget {
  final LotStatus status;
  final String? title;
  final List<TimelineStage>? customStages;

  const FulfillmentTimeline({
    super.key,
    required this.status,
    this.title,
    this.customStages,
  });

  int _getStepIndex(LotStatus st) {
    switch (st) {
      case LotStatus.completed:
        return 3;
      case LotStatus.delivered:
        return 2;
      case LotStatus.picked:
        return 1;
      case LotStatus.accepted:
        return 0;
      case LotStatus.pending:
      case LotStatus.cancelled:
        return -1;
    }
  }

  List<TimelineStage> _resolveStages(BuildContext context) {
    if (customStages != null && customStages!.isNotEmpty) {
      return customStages!;
    }

    final isMarathi = context.isMarathi;
    final isEnglish = context.isEnglish;

    if (isMarathi) {
      return const [
        TimelineStage(
          title: 'लॉट स्वीकारला',
          description: 'रीसायकलरने स्क्रॅप विनंती मान्य केली आहे.',
        ),
        TimelineStage(
          title: 'पिकअप रवाना',
          description: 'कचरा उचलण्यासाठी वाहन निघत आहे.',
        ),
        TimelineStage(
          title: 'वजन पडताळणी व डिलिव्हरी',
          description: 'काट्यावर प्रत्यक्ष वजन मोजले गेले आहे.',
        ),
        TimelineStage(
          title: 'पुनर्चक्रीकरण पूर्ण',
          description: 'व्यवहार यशस्वीरीत्या पूर्ण झाला आहे.',
        ),
      ];
    }

    if (isEnglish) {
      return const [
        TimelineStage(
          title: 'Lot Accepted',
          description: 'Recycler matched and accepted scrap lot terms.',
        ),
        TimelineStage(
          title: 'Pickup Dispatched',
          description: 'Driver dispatched to inspect and collect material.',
        ),
        TimelineStage(
          title: 'Weight Verified & Delivered',
          description: 'Material delivered and calibrated on digital scale.',
        ),
        TimelineStage(
          title: 'Completed & Recycled',
          description: 'Transaction settled and recorded in ledger.',
        ),
      ];
    }

    // Default Hindi
    return const [
      TimelineStage(
        title: 'लॉट स्वीकार किया गया',
        description: 'रीसाइक्लर ने कबाड़ लॉट की शर्तें स्वीकार कर ली हैं।',
      ),
      TimelineStage(
        title: 'पिकअप रवाना',
        description: 'सामग्री लेने के लिए वाहन रवाना हो चुका है।',
      ),
      TimelineStage(
        title: 'वजन सत्यापन एवं डिलीवरी',
        description: 'कांटे पर सामग्री का वास्तविक वजन दर्ज कर लिया गया है।',
      ),
      TimelineStage(
        title: 'पुनर्चक्रण पूर्ण',
        description: 'लेन-देन सफलतापूर्वक पूरा हो चुका है।',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stages = _resolveStages(context);
    final currentIndex = _getStepIndex(status);

    final sectionTitle =
        title ??
        (context.isMarathi
            ? 'ऑर्डरची प्रगती (लाइफसायकल)'
            : context.isEnglish
            ? 'Fulfillment Lifecycle'
            : 'ऑर्डर की स्थिति (लाइफसाइकिल)');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < stages.length; i++)
            _buildTimelineItem(
              stage: stages[i],
              index: i,
              isLast: i == stages.length - 1,
              isCompleted: i < currentIndex,
              isCurrent: i == currentIndex,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required TimelineStage stage,
    required int index,
    required bool isLast,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color circleBg;
    Color iconColor;
    Widget iconWidget;

    if (isCompleted) {
      circleBg = AppColors.greenPrimary;
      iconColor = Colors.white;
      iconWidget = const Icon(
        Icons.check_rounded,
        size: 14,
        color: Colors.white,
      );
    } else if (isCurrent) {
      circleBg = AppColors.saffronPrimary;
      iconColor = Colors.white;
      iconWidget = const Icon(
        Icons.check_rounded,
        size: 14,
        color: Colors.white,
      );
    } else {
      circleBg = AppColors.border;
      iconColor = AppColors.dark400;
      iconWidget = Icon(Icons.schedule_rounded, size: 14, color: iconColor);
    }

    final titleColor = isCurrent
        ? AppColors.saffronDark
        : (isCompleted ? AppColors.dark900 : AppColors.dark400);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + circle
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppColors.saffron100, width: 3.5)
                      : null,
                ),
                child: Center(child: iconWidget),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? AppColors.greenPrimary
                        : AppColors.borderMedium,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w700,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stage.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCurrent ? AppColors.dark700 : AppColors.dark500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
