import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../feedback/status_badge.dart';
import 'app_card.dart';

class UserStatusCard extends StatelessWidget {
  final UserModel user;
  final bool canManage;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onChangeRole;

  const UserStatusCard({
    super.key,
    required this.user,
    this.canManage = false,
    this.onActivate,
    this.onDeactivate,
    this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildRoleBadge(user.role),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user.email,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phone!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildStatusBadge(user.status),
          if (canManage) ...[
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              onSelected: (action) {
                if (action == 'activate') onActivate?.call();
                if (action == 'deactivate') onDeactivate?.call();
                if (action == 'role') onChangeRole?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                if (user.status == UserStatus.active)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.block_rounded, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Deactivate User', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Activate User', style: TextStyle(color: AppColors.success)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    StatusBadgeVariant variant;
    switch (role) {
      case UserRole.administrator:
        variant = StatusBadgeVariant.warning;
        break;
      case UserRole.dentist:
        variant = StatusBadgeVariant.primary;
        break;
      case UserRole.staff:
        variant = StatusBadgeVariant.neutral;
        break;
    }

    return StatusBadge(
      label: role.displayName,
      variant: variant,
      fontSize: 10,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    StatusBadgeVariant variant;
    IconData? icon;

    switch (status) {
      case UserStatus.active:
        variant = StatusBadgeVariant.success;
        icon = Icons.check_circle_rounded;
        break;
      case UserStatus.inactive:
        variant = StatusBadgeVariant.error;
        icon = Icons.cancel_rounded;
        break;
      case UserStatus.invited:
        variant = StatusBadgeVariant.warning;
        icon = Icons.mail_outline_rounded;
        break;
    }

    return StatusBadge(
      label: status.displayName,
      variant: variant,
      icon: icon,
      fontSize: 11,
    );
  }
}
