import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/verification_bloc.dart';
import '../view_model/verification_event.dart';
import '../view_model/verification_state.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    this.email = 'contact@apexdental.com',
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state.isVerified) {
          Navigator.of(context).pushReplacementNamed(RouteNames.subscriptionPlans);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: 'Verify Your Email Address',
          subtitle: 'We sent an email verification link to $email.',
          footer: _buildFooter(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Verification Incomplete',
                  message: state.errorMessage,
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.successMessage != null) ...[
                StatusCard(
                  title: 'Notification Sent',
                  message: state.successMessage,
                  type: StatusType.success,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(50),
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check your inbox & spam folder', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Click the link inside to activate your account.', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: "I've Clicked the Verification Link",
                isLoading: state.isLoading,
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => context.read<VerificationBloc>().add(CheckEmailVerificationStatus(email)),
              ),
              const SizedBox(height: AppSpacing.md),

              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.otpVerification),
                icon: const Icon(Icons.pin_outlined, size: 18),
                label: const Text('Verify using 6-Digit OTP instead'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: state.canResend
                    ? TextButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<VerificationBloc>().add(ResendVerificationEmailRequested(email)),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Resend Verification Email'),
                      )
                    : Text(
                        'Resend available in ${state.resendCooldownSeconds}s',
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
          onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.clinicOnboarding),
          child: const Text('Edit Clinic Registration'),
        ),
        const Text('•'),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.login),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
