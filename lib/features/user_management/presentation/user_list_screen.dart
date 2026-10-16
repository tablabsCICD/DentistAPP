import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/cards/user_status_card.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../../authentication/view_model/auth_bloc.dart';
import '../view_model/user_management_bloc.dart';
import '../view_model/user_management_event.dart';
import '../view_model/user_management_state.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserManagementBloc>().add(LoadTeamMembersRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showChangeRoleDialog(UserModel user, UserModel currentUser) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change Role: ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Dentist / Clinician'),
                subtitle: const Text('Can access clinical records and AI diagnostic tools'),
                leading: Icon(
                  selectedRole == UserRole.dentist ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selectedRole == UserRole.dentist ? AppColors.primary : AppColors.textTertiary,
                ),
                onTap: () => setDialogState(() => selectedRole = UserRole.dentist),
              ),
              ListTile(
                title: const Text('Clinic Staff'),
                subtitle: const Text('Can manage appointments, front desk, and patient intake'),
                leading: Icon(
                  selectedRole == UserRole.staff ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selectedRole == UserRole.staff ? AppColors.primary : AppColors.textTertiary,
                ),
                onTap: () => setDialogState(() => selectedRole = UserRole.staff),
              ),
              ListTile(
                title: const Text('Clinic Administrator'),
                subtitle: const Text('Full practice administrative and billing privileges'),
                leading: Icon(
                  selectedRole == UserRole.administrator ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selectedRole == UserRole.administrator ? AppColors.primary : AppColors.textTertiary,
                ),
                onTap: () => setDialogState(() => selectedRole = UserRole.administrator),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<UserManagementBloc>().add(
                      ChangeUserRoleRequested(
                        currentUser: currentUser,
                        userId: user.id,
                        newRole: selectedRole,
                      ),
                    );
              },
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user ??
        const UserModel(
          id: 'usr-admin-default',
          email: 'admin@clinic.com',
          firstName: 'Elena',
          lastName: 'Rostova',
          role: UserRole.administrator,
          permissions: UserPermissions(
            canInviteUsers: true,
            canActivateUsers: true,
            canDeactivateUsers: true,
            canChangeUserRole: true,
          ),
        );

    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: 'Clinical Team & Staff Management',
      currentRoute: RouteNames.users,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<UserManagementBloc>().add(LoadTeamMembersRequested()),
          tooltip: 'Refresh Directory',
        ),
      ],
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.users.isEmpty) {
            return const AppLoading(message: 'Loading clinic user directory...');
          }

          final users = state.filteredUsers;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!authUser.permissions.canInviteUsers) ...[
                StatusCard(
                  title: 'Limited Access: ${authUser.role.displayName}',
                  message: 'You have read-only access to the clinic team directory. Administrative actions require Administrator role.',
                  type: StatusType.info,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'User Management Error',
                  message: state.errorMessage,
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Top Bar with Search & Invite Button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;

                  if (isNarrow && authUser.permissions.canInviteUsers) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _searchController,
                          hint: 'Search staff by name, email, or role...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          onChanged: (q) => context.read<UserManagementBloc>().add(SearchQueryChanged(q)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          text: 'Invite Member',
                          icon: Icons.person_add_rounded,
                          onPressed: () => Navigator.of(context).pushNamed(RouteNames.inviteUser),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _searchController,
                          hint: 'Search staff by name, email, or role...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          onChanged: (q) => context.read<UserManagementBloc>().add(SearchQueryChanged(q)),
                        ),
                      ),
                      if (authUser.permissions.canInviteUsers) ...[
                        const SizedBox(width: AppSpacing.md),
                        PrimaryButton(
                          text: 'Invite Member',
                          icon: Icons.person_add_rounded,
                          width: 170,
                          onPressed: () => Navigator.of(context).pushNamed(RouteNames.inviteUser),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              if (users.isEmpty)
                AppEmptyState(
                  title: 'No Team Members Found',
                  message: state.searchQuery.isNotEmpty
                      ? 'No users match "${state.searchQuery}". Try a different keyword.'
                      : 'Invite your first clinic colleague or dental surgeon to start collaborating.',
                  actionText: authUser.permissions.canInviteUsers ? 'Invite Team Member' : null,
                  onAction: authUser.permissions.canInviteUsers
                      ? () => Navigator.of(context).pushNamed(RouteNames.inviteUser)
                      : null,
                )
              else if (isDesktop)
                _buildDesktopTable(users, authUser)
              else
                _buildMobileList(users, authUser),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(List<UserModel> users, UserModel currentUser) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            children: [
              _buildTableHeader('Team Member'),
              _buildTableHeader('Email / Contact'),
              _buildTableHeader('Role'),
              _buildTableHeader('Status'),
              _buildTableHeader('Actions'),
            ],
          ),
          ...users.map((user) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.primary,
                        child: Text(
                          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: AppTypography.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    user.email,
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildRoleBadge(user.role),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildStatusBadge(user.status),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (currentUser.permissions.canChangeUserRole)
                        IconButton(
                          icon: const Icon(Icons.badge_outlined, size: 18),
                          tooltip: 'Change Role',
                          onPressed: () => _showChangeRoleDialog(user, currentUser),
                        ),
                      if (currentUser.permissions.canDeactivateUsers && user.status == UserStatus.active)
                        IconButton(
                          icon: const Icon(Icons.block_rounded, size: 18, color: AppColors.error),
                          tooltip: 'Deactivate',
                          onPressed: () => context.read<UserManagementBloc>().add(
                                ToggleUserStatusRequested(
                                  currentUser: currentUser,
                                  userId: user.id,
                                  newStatus: UserStatus.inactive,
                                ),
                              ),
                        ),
                      if (currentUser.permissions.canActivateUsers && user.status == UserStatus.inactive)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
                          tooltip: 'Activate',
                          onPressed: () => context.read<UserManagementBloc>().add(
                                ToggleUserStatusRequested(
                                  currentUser: currentUser,
                                  userId: user.id,
                                  newStatus: UserStatus.active,
                                ),
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<UserModel> users, UserModel currentUser) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserStatusCard(
          user: user,
          canManage: currentUser.permissions.canInviteUsers,
          onChangeRole: () => _showChangeRoleDialog(user, currentUser),
          onActivate: () => context.read<UserManagementBloc>().add(
                ToggleUserStatusRequested(
                  currentUser: currentUser,
                  userId: user.id,
                  newStatus: UserStatus.active,
                ),
              ),
          onDeactivate: () => context.read<UserManagementBloc>().add(
                ToggleUserStatusRequested(
                  currentUser: currentUser,
                  userId: user.id,
                  newStatus: UserStatus.inactive,
                ),
              ),
        );
      },
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color bg;
    Color fg;
    switch (role) {
      case UserRole.administrator:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        break;
      case UserRole.dentist:
        bg = AppColors.primaryContainer;
        fg = AppColors.primary;
        break;
      case UserRole.staff:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        role.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    Color color = status == UserStatus.active
        ? AppColors.success
        : (status == UserStatus.inactive ? AppColors.error : AppColors.warning);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: AppSpacing.xs),
        Text(status.displayName, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
