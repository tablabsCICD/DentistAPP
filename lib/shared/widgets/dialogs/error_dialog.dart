import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../buttons/primary_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String closeText;
  final VoidCallback? onClose;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.closeText = 'Close',
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String closeText = 'Close',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        closeText: closeText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(title, style: AppTypography.titleLarge.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryButton(
                  text: closeText,
                  width: 100,
                  height: 38,
                  backgroundColor: AppColors.error,
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onAction;

  const SuccessDialog({
    super.key,
    this.title = 'Success',
    required this.message,
    this.actionText = 'Continue',
    this.onAction,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Success',
    required String message,
    String actionText = 'Continue',
    VoidCallback? onAction,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        actionText: actionText,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(title, style: AppTypography.titleLarge.copyWith(color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryButton(
                  text: actionText,
                  width: 120,
                  height: 38,
                  backgroundColor: AppColors.success,
                  onPressed: onAction ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
