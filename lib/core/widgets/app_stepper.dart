import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Represents a single milestone in [AppStepper].
class AppStepItem {
  final int number;
  final String title;

  const AppStepItem({
    required this.number,
    required this.title,
  });
}

/// A guided 3-step numbered visual progress bar matching prototype `Stepper.tsx`.
/// Displays clear numbered circles, green checkmarks for completed milestones,
/// and saffron highlighting for the active step.
class AppStepper extends StatelessWidget {
  final List<AppStepItem> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const AppStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _buildStep(steps[i]),
            ),
            if (i < steps.length - 1)
              _buildConnector(isCompleted: currentStep > steps[i].number),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(AppStepItem step) {
    final isCompleted = currentStep > step.number;
    final isCurrent = currentStep == step.number;

    Color circleBg;
    Widget circleChild;
    BoxBorder? outerRing;

    if (isCompleted) {
      circleBg = AppColors.greenPrimary;
      circleChild = const Icon(Icons.check_rounded, size: 16, color: Colors.white);
      outerRing = null;
    } else if (isCurrent) {
      circleBg = AppColors.saffronPrimary;
      circleChild = Text(
        '${step.number}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      outerRing = Border.all(color: AppColors.saffron100, width: 3.5);
    } else {
      circleBg = AppColors.border;
      circleChild = Text(
        '${step.number}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.dark500,
        ),
      );
      outerRing = Border.all(color: AppColors.borderMedium, width: 1.0);
    }

    final titleColor = isCurrent
        ? AppColors.dark900
        : (isCompleted ? AppColors.dark700 : AppColors.dark400);

    return InkWell(
      onTap: isCompleted && onStepTapped != null
          ? () => onStepTapped!(step.number)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: outerRing,
              ),
              child: Center(child: circleChild),
            ),
            const SizedBox(height: 6),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: titleColor,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      width: 24,
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.greenPrimary : AppColors.borderMedium,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
