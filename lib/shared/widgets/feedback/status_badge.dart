import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

enum StatusBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final IconData? icon;
  final bool isPill;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.icon,
    this.isPill = true,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, borderColor) = _getColors();

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isPill
            ? BorderRadius.circular(9999)
            : AppSpacing.borderRadiusSm,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: (fontSize ?? 12) + 2,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize ?? 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _getColors() {
    switch (variant) {
      case StatusBadgeVariant.success:
        return (
          AppColors.successContainer,
          AppColors.success,
          AppColors.success.withValues(alpha: 0.2),
        );
      case StatusBadgeVariant.warning:
        return (
          AppColors.warningContainer,
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.2),
        );
      case StatusBadgeVariant.error:
        return (
          AppColors.errorContainer,
          AppColors.error,
          AppColors.error.withValues(alpha: 0.2),
        );
      case StatusBadgeVariant.info:
        return (
          AppColors.infoContainer,
          AppColors.info,
          AppColors.info.withValues(alpha: 0.2),
        );
      case StatusBadgeVariant.primary:
        return (
          AppColors.primaryContainer,
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.25),
        );
      case StatusBadgeVariant.neutral:
        return (
          AppColors.surfaceVariant,
          AppColors.textSecondary,
          AppColors.border,
        );
    }
  }
}
