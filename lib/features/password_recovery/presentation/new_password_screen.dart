import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/password_recovery_bloc.dart';
import '../view_model/password_recovery_event.dart';
import '../view_model/password_recovery_state.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSetNewPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<PasswordRecoveryBloc>().add(
            NewPasswordSubmitted(_passwordController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      listener: (context, state) {
        if (state.step == PasswordRecoveryStep.success) {
          Navigator.of(context).pushReplacementNamed(RouteNames.passwordResetSuccess);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: 'Create New Password',
          subtitle: 'Ensure your new password meets clinical SaaS security requirements.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMessage != null) ...[
                  StatusCard(
                    title: 'Password Update Failed',
                    message: state.errorMessage,
                    type: StatusType.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppPasswordField(
                  controller: _passwordController,
                  label: 'New Password',
                  hint: 'Min 8 chars, 1 uppercase, 1 number, 1 symbol',
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Re-enter your new password',
                  enabled: !state.isLoading,
                  customValidator: (val) => AppValidators.confirmPassword(val, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.md),

                // Password requirements checklist
                _buildRequirementsList(),
                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  text: 'Update Password & Continue',
                  isLoading: state.isLoading,
                  icon: Icons.check_rounded,
                  onPressed: _onSetNewPassword,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementsList() {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD REQUIREMENTS:',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCheckItem('At least 8 characters long'),
          _buildCheckItem('At least 1 uppercase and 1 lowercase letter'),
          _buildCheckItem('At least 1 numerical digit and 1 special symbol'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
