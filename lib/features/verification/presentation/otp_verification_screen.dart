import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_otp_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/verification_bloc.dart';
import '../view_model/verification_event.dart';
import '../view_model/verification_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    this.email = 'contact@apexdental.com',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredCode = '';

  void _onVerify(String code) {
    if (code.length == 6) {
      context.read<VerificationBloc>().add(
            VerifyOtpSubmitted(email: widget.email, otp: code),
          );
    }
  }

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
          title: 'Enter Verification Code',
          subtitle: 'A 6-digit activation code was sent to ${widget.email}.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Verification Error',
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
                onChanged: (val) => setState(() => _enteredCode = val),
                onCompleted: _onVerify,
              ),
              const SizedBox(height: AppSpacing.lg),

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
                        'Demo OTP: Use 123456 to verify, or 000000 to test expired token.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                text: 'Verify Account',
                isLoading: state.isLoading,
                onPressed: _enteredCode.length == 6 ? () => _onVerify(_enteredCode) : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: state.canResend
                    ? TextButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<VerificationBloc>().add(ResendVerificationOtpRequested(widget.email)),
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
}
