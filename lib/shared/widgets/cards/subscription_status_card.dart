import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../models/subscription_model.dart';
import '../feedback/status_badge.dart';
import 'app_card.dart';
import 'status_card.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final CurrentSubscription subscription;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDowngrade;
  final VoidCallback? onCancel;
  final VoidCallback? onRetryPayment;

  const SubscriptionStatusCard({
    super.key,
    required this.subscription,
    this.onUpgrade,
    this.onDowngrade,
    this.onCancel,
    this.onRetryPayment,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Column(
      children: [
        if (subscription.hasPaymentFailed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StatusCard(
              title: 'Payment Failed',
              message: subscription.lastPaymentError ??
                  'We were unable to process your latest payment. Please update your payment method or retry the payment.',
              type: StatusType.error,
              action: onRetryPayment != null
                  ? ElevatedButton(
                      onPressed: onRetryPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry Payment Now'),
                    )
                  : null,
            ),
          ),
        if (subscription.isInGracePeriod)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StatusCard(
              title: 'Payment Issue - Grace Period Active',
              message:
                  'Your subscription is currently in a grace period until ${subscription.gracePeriodEndsAt != null ? dateFormatter.format(subscription.gracePeriodEndsAt!) : 'soon'}. Please resolve payment to keep AI services active.',
              type: StatusType.warning,
              action: onRetryPayment != null
                  ? ElevatedButton(
                      onPressed: onRetryPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pay Invoice'),
                    )
                  : null,
            ),
          ),
        AppCard(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT PLAN',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subscription.plan.name,
                        style: AppTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(subscription.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    subscription.plan.formattedPrice,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Text(
                      'Next Renewal: ${dateFormatter.format(subscription.renewalDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (onUpgrade != null)
                    ElevatedButton.icon(
                      onPressed: onUpgrade,
                      icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                      label: const Text('Upgrade Plan'),
                    ),
                  if (onDowngrade != null)
                    OutlinedButton(
                      onPressed: onDowngrade,
                      child: const Text('Change Plan'),
                    ),
                  if (onCancel != null && !subscription.isCancelled)
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Cancel Subscription'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    StatusBadgeVariant variant;
    IconData? icon;

    switch (status) {
      case SubscriptionStatus.active:
        variant = StatusBadgeVariant.success;
        icon = Icons.check_circle_rounded;
        break;
      case SubscriptionStatus.gracePeriod:
      case SubscriptionStatus.paymentPending:
      case SubscriptionStatus.pending:
        variant = StatusBadgeVariant.warning;
        icon = Icons.hourglass_top_rounded;
        break;
      case SubscriptionStatus.paymentFailed:
      case SubscriptionStatus.blocked:
      case SubscriptionStatus.expired:
        variant = StatusBadgeVariant.error;
        icon = Icons.error_rounded;
        break;
      case SubscriptionStatus.cancelled:
        variant = StatusBadgeVariant.neutral;
        icon = Icons.cancel_outlined;
        break;
    }

    return StatusBadge(
      label: status.displayName.toUpperCase(),
      variant: variant,
      icon: icon,
    );
  }
}
