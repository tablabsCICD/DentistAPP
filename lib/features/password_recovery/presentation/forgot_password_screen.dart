import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/password_recovery_bloc.dart';
import '../view_model/password_recovery_event.dart';
import '../view_model/password_recovery_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dentist@clinic.com');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<PasswordRecoveryBloc>().add(
            RequestResetSubmitted(_emailController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      listener: (context, state) {
        if (state.step == PasswordRecoveryStep.resetCode) {
          Navigator.of(context).pushReplacementNamed(RouteNames.resetCode);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: 'Reset Password',
          subtitle: 'Enter your registered clinic email to receive a 6-digit verification code.',
          footer: _buildBackToLogin(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMessage != null) ...[
                  StatusCard(
                    title: 'Reset Request Failed',
                    message: state.errorMessage,
                    type: StatusType.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppEmailField(
                  controller: _emailController,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  text: 'Send Verification Code',
                  isLoading: state.isLoading,
                  icon: Icons.send_rounded,
                  onPressed: _onSubmit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        context.read<PasswordRecoveryBloc>().add(ResetFlowReset());
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      },
      icon: const Icon(Icons.arrow_back_rounded, size: 16),
      label: Text(
        'Back to Login',
        style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
