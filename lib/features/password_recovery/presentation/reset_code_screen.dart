import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_otp_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/password_recovery_bloc.dart';
import '../view_model/password_recovery_event.dart';
import '../view_model/password_recovery_state.dart';

class ResetCodeScreen extends StatefulWidget {
  const ResetCodeScreen({super.key});

  @override
  State<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends State<ResetCodeScreen> {
  String _enteredCode = '';

  void _onVerifyCode(String code) {
    if (code.length == 6) {
      context.read<PasswordRecoveryBloc>().add(ResetCodeSubmitted(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      listener: (context, state) {
        if (state.step == PasswordRecoveryStep.newPassword) {
          Navigator.of(context).pushReplacementNamed(RouteNames.newPassword);
        }
      },
      builder: (context, state) {
        final emailDisplay = state.email.isNotEmpty ? state.email.maskEmail : 'your email address';

        return AuthLayout(
          title: 'Enter Verification Code',
          subtitle: 'We sent a 6-digit verification code to $emailDisplay.',
          footer: _buildFooter(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Verification Failed',
                  message: state.errorMessage,
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.successMessage != null) ...[
                StatusCard(
                  title: 'Code Sent',
                  message: state.successMessage,
                  type: StatusType.success,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              AppOtpField(
                length: 6,
                enabled: !state.isLoading,
                onChanged: (code) => setState(() => _enteredCode = code),
                onCompleted: _onVerifyCode,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Demo hint box
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Demo Codes: Use 123456 to succeed, or 000000 to test expired code.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                text: 'Verify Code',
                isLoading: state.isLoading,
                onPressed: _enteredCode.length == 6 ? () => _onVerifyCode(_enteredCode) : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: state.canResend
                    ? TextButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<PasswordRecoveryBloc>().add(ResendResetCodeRequested()),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Resend Code'),
                      )
                    : Text(
                        'Resend code in ${state.resendCooldownSeconds}s',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(RouteNames.forgotPassword);
          },
          child: const Text('Change Email'),
        ),
        const Text('•'),
        TextButton(
          onPressed: () {
            context.read<PasswordRecoveryBloc>().add(ResetFlowReset());
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
