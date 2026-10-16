import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/feedback/app_success_state.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../authentication/view_model/auth_bloc.dart';
import '../view_model/user_management_bloc.dart';
import '../view_model/user_management_event.dart';
import '../view_model/user_management_state.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  UserRole _selectedRole = UserRole.dentist;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onSendInvitation(UserModel currentUser) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserManagementBloc>().add(
            InviteUserSubmitted(
              currentUser: currentUser,
              email: _emailController.text,
              role: _selectedRole,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            ),
          );
    }
  }

  void _resetForm() {
    setState(() {
      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _selectedRole = UserRole.dentist;
    });
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
          permissions: UserPermissions(canInviteUsers: true),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invite Team Member'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: BlocBuilder<UserManagementBloc, UserManagementState>(
              builder: (context, state) {
                if (state.isInviteSuccess) {
                  return AppCard(
                    padding: AppSpacing.paddingXl,
                    child: AppSuccessState(
                      title: 'Invitation Dispatched!',
                      message:
                          'An onboarding invitation link with credentials has been delivered to ${_emailController.text.isNotEmpty ? _emailController.text : 'the user'}.',
                      actionText: 'Invite Another Colleague',
                      onAction: _resetForm,
                    ),
                  );
                }

                return AppCard(
                  padding: AppSpacing.paddingXl,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Send Team Invitation', style: AppTypography.titleLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Invite doctors, dental hygienists, or front desk staff to your clinical tenant.',
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        if (!authUser.permissions.canInviteUsers) ...[
                          const StatusCard(
                            title: 'Permission Denied',
                            message: 'Only Clinic Administrators can invite new staff members.',
                            type: StatusType.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        if (state.errorMessage != null) ...[
                          StatusCard(
                            title: 'Invitation Failed',
                            message: state.errorMessage,
                            type: StatusType.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _firstNameController,
                                label: 'First Name *',
                                hint: 'e.g., Marcus',
                                enabled: authUser.permissions.canInviteUsers && !state.isLoading,
                                validator: (v) => AppValidators.requiredField(v, 'First Name'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppTextField(
                                controller: _lastNameController,
                                label: 'Last Name *',
                                hint: 'e.g., Vance',
                                enabled: authUser.permissions.canInviteUsers && !state.isLoading,
                                validator: (v) => AppValidators.requiredField(v, 'Last Name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        AppEmailField(
                          controller: _emailController,
                          label: 'Work Email Address *',
                          hint: 'colleague@apexdental.com',
                          enabled: authUser.permissions.canInviteUsers && !state.isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        AppDropdown<UserRole>(
                          label: 'Assigned Clinical Role *',
                          value: _selectedRole,
                          enabled: authUser.permissions.canInviteUsers && !state.isLoading,
                          items: const [
                            DropdownMenuItem(
                              value: UserRole.dentist,
                              child: Text('Dentist / Clinician'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.staff,
                              child: Text('Clinic Staff'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.administrator,
                              child: Text('Clinic Administrator'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        PrimaryButton(
                          text: 'Send Official Invitation',
                          isLoading: state.isLoading,
                          icon: Icons.send_rounded,
                          onPressed: authUser.permissions.canInviteUsers ? () => _onSendInvitation(authUser) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
