import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/progress_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../view_model/onboarding_status_bloc.dart';
import '../view_model/onboarding_status_event.dart';
import '../view_model/onboarding_status_state.dart';

class OnboardingStatusScreen extends StatefulWidget {
  const OnboardingStatusScreen({super.key});

  @override
  State<OnboardingStatusScreen> createState() => _OnboardingStatusScreenState();
}

class _OnboardingStatusScreenState extends State<OnboardingStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingStatusBloc>().add(FetchOnboardingStatusRequested());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Clinic Activation & Onboarding',
      currentRoute: RouteNames.onboardingStatus,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<OnboardingStatusBloc>().add(FetchOnboardingStatusRequested()),
          tooltip: 'Refresh Status',
        ),
      ],
      body: BlocBuilder<OnboardingStatusBloc, OnboardingStatusState>(
        builder: (context, state) {
          if (state.isLoading && state.clinic == null) {
            return const AppLoading(message: 'Checking clinic registration and activation status...');
          }

          final clinic = state.clinic ??
              const ClinicDetails(
                id: 'cln-01',
                name: 'Apex Dental Care',
                clinicType: 'Multi-Speciality Practice',
                address: '42 Medical Enclave',
                city: 'Bengaluru',
                state: 'Karnataka',
                country: 'India',
                postalCode: '560001',
                primaryContactName: 'Dr. Elena Rostova',
                primaryPhone: '+91 98765 43210',
                primaryEmail: 'contact@apexdental.com',
                status: ClinicStatus.pending,
                onboardingStatus: InternalOnboardingStatus.subscriptionPending,
              );

          final subscription = state.subscription;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClinicHeaderBanner(clinic),
              const SizedBox(height: AppSpacing.lg),

              if (clinic.status == ClinicStatus.blocked) ...[
                const StatusCard(
                  title: 'Clinic Account Blocked / Suspended',
                  message:
                      'Access to this clinic portal has been temporarily suspended by system administrators. Please reach out to support@dentflow.ai.',
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (!clinic.isEmailVerified) ...[
                StatusCard(
                  title: 'Action Required: Email Verification Pending',
                  message: 'Your administrator email has not been verified yet.',
                  type: StatusType.warning,
                  action: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(RouteNames.emailVerification),
                    child: const Text('Verify Email Now'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (clinic.isEmailVerified && (subscription == null || subscription.status != SubscriptionStatus.active)) ...[
                StatusCard(
                  title: 'Action Required: Subscription Inactive',
                  message: 'Select a monthly clinical tier to activate your AI diagnostics and team portal.',
                  type: StatusType.warning,
                  action: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(RouteNames.subscriptionPlans),
                    child: const Text('Choose Subscription Plan'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              ProgressCard(
                title: 'Onboarding & Activation Progress',
                subtitle: 'Track setup requirements before full clinical access is granted.',
                steps: [
                  StepItem(
                    title: '1. Clinic Profile Setup',
                    subtitle: '${clinic.name} (${clinic.clinicType}) registered.',
                    state: OnboardingStepState.completed,
                  ),
                  StepItem(
                    title: '2. Administrator Email Verification',
                    subtitle: clinic.isEmailVerified
                        ? 'Email verified (${clinic.primaryEmail})'
                        : 'Pending verification for ${clinic.primaryEmail}',
                    state: clinic.isEmailVerified ? OnboardingStepState.completed : OnboardingStepState.inProgress,
                    actionLabel: clinic.isEmailVerified ? null : 'Verify',
                    onAction: clinic.isEmailVerified
                        ? null
                        : () => Navigator.of(context).pushNamed(RouteNames.emailVerification),
                  ),
                  StepItem(
                    title: '3. Clinical SaaS Subscription',
                    subtitle: subscription != null && subscription.isActive
                        ? '${subscription.plan.name} plan active (${subscription.plan.formattedPrice})'
                        : 'Select a tier to enable AI scans and user seats',
                    state: subscription != null && subscription.isActive
                        ? OnboardingStepState.completed
                        : (clinic.isEmailVerified ? OnboardingStepState.inProgress : OnboardingStepState.pending),
                    actionLabel: subscription != null && subscription.isActive ? null : 'Select Plan',
                    onAction: () => Navigator.of(context).pushNamed(RouteNames.subscriptionPlans),
                  ),
                  StepItem(
                    title: '4. Clinic Portal Activation',
                    subtitle: clinic.status == ClinicStatus.active
                        ? 'Clinic is fully ACTIVE and operational'
                        : (clinic.status == ClinicStatus.blocked
                            ? 'Clinic is currently BLOCKED'
                            : 'Pending prerequisite step completion'),
                    state: clinic.status == ClinicStatus.active
                        ? OnboardingStepState.completed
                        : (clinic.status == ClinicStatus.blocked ? OnboardingStepState.failed : OnboardingStepState.pending),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              if (clinic.status == ClinicStatus.active)
                AppCard(
                  backgroundColor: AppColors.successContainer,
                  borderColor: AppColors.success.withAlpha(80),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 500;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Clinic is Ready for Clinical Practice!',
                                      style: AppTypography.titleMedium.copyWith(color: AppColors.success),
                                    ),
                                    Text(
                                      'You can now invite team members and configure clinic settings.',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isNarrow) ...[
                                const SizedBox(width: AppSpacing.md),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pushNamed(RouteNames.clinicSettings),
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ],
                          ),
                          if (isNarrow) ...[
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pushNamed(RouteNames.clinicSettings),
                                child: const Text('Open Settings'),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClinicHeaderBanner(ClinicDetails clinic) {
    return AppCard(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(clinic.name, style: AppTypography.headlineMedium),
                    _buildClinicStatusBadge(clinic.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${clinic.clinicType} • ${clinic.city}, ${clinic.country}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicStatusBadge(ClinicStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case ClinicStatus.active:
        bg = AppColors.successContainer;
        fg = AppColors.success;
        break;
      case ClinicStatus.pending:
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        break;
      case ClinicStatus.blocked:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
