import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import 'app_card.dart';

enum OnboardingStepState {
  completed,
  inProgress,
  pending,
  failed,
}

class StepItem {
  final String title;
  final String? subtitle;
  final OnboardingStepState state;
  final VoidCallback? onAction;
  final String? actionLabel;

  const StepItem({
    required this.title,
    this.subtitle,
    required this.state,
    this.onAction,
    this.actionLabel,
  });
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<StepItem> steps;

  const ProgressCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Container(
                width: 2,
                height: 16,
                color: AppColors.border,
              ),
            ),
            itemBuilder: (context, index) {
              final step = steps[index];
              return _buildStepRow(step);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(StepItem step) {
    Widget iconWidget;
    Color titleColor = AppColors.textPrimary;

    switch (step.state) {
      case OnboardingStepState.completed:
        iconWidget = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24);
        break;
      case OnboardingStepState.inProgress:
        iconWidget = const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary, size: 24);
        break;
      case OnboardingStepState.failed:
        iconWidget = const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24);
        titleColor = AppColors.error;
        break;
      case OnboardingStepState.pending:
        iconWidget = const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textTertiary, size: 24);
        titleColor = AppColors.textSecondary;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconWidget,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: AppTypography.titleMedium.copyWith(color: titleColor),
              ),
              if (step.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(step.subtitle!, style: AppTypography.bodySmall),
              ],
            ],
          ),
        ),
        if (step.onAction != null && step.actionLabel != null)
          TextButton(
            onPressed: step.onAction,
            child: Text(step.actionLabel!),
          ),
      ],
    );
  }
}
