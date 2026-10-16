import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import 'app_card.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
}

class StatusCard extends StatelessWidget {
  final String title;
  final String? message;
  final StatusType type;
  final Widget? action;
  final IconData? customIcon;

  const StatusCard({
    super.key,
    required this.title,
    this.message,
    this.type = StatusType.info,
    this.action,
    this.customIcon,
  });

  Color get _color {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.textSecondary;
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusType.success:
        return AppColors.successContainer;
      case StatusType.warning:
        return AppColors.warningContainer;
      case StatusType.error:
        return AppColors.errorContainer;
      case StatusType.info:
        return AppColors.infoContainer;
      case StatusType.neutral:
        return AppColors.surfaceVariant;
    }
  }

  IconData get _icon {
    if (customIcon != null) return customIcon!;
    switch (type) {
      case StatusType.success:
        return Icons.check_circle_outline_rounded;
      case StatusType.warning:
        return Icons.warning_amber_rounded;
      case StatusType.error:
        return Icons.error_outline_rounded;
      case StatusType.info:
        return Icons.info_outline_rounded;
      case StatusType.neutral:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: _backgroundColor,
      borderColor: _color.withAlpha(50),
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
