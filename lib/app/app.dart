import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/view_model/auth_bloc.dart';
import '../features/clinic_onboarding/data/clinic_onboarding_repository.dart';
import '../features/clinic_onboarding/view_model/clinic_onboarding_bloc.dart';
import '../features/clinic_settings/data/clinic_settings_repository.dart';
import '../features/clinic_settings/view_model/clinic_settings_bloc.dart';
import '../features/onboarding_status/data/onboarding_status_repository.dart';
import '../features/onboarding_status/view_model/onboarding_status_bloc.dart';
import '../features/password_recovery/data/password_recovery_repository.dart';
import '../features/password_recovery/view_model/password_recovery_bloc.dart';
import '../features/payment/data/payment_repository.dart';
import '../features/payment/view_model/payment_bloc.dart';
import '../features/subscription/data/subscription_repository.dart';
import '../features/subscription/view_model/subscription_bloc.dart';
import '../features/user_management/data/user_management_repository.dart';
import '../features/user_management/view_model/user_management_bloc.dart';
import '../features/verification/data/verification_repository.dart';
import '../features/verification/view_model/verification_bloc.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'theme/app_theme.dart';

class DentalApp extends StatelessWidget {
  final AuthRepository? authRepository;
  final PasswordRecoveryRepository? passwordRecoveryRepository;
  final ClinicOnboardingRepository? clinicOnboardingRepository;
  final VerificationRepository? verificationRepository;
  final OnboardingStatusRepository? onboardingStatusRepository;
  final SubscriptionRepository? subscriptionRepository;
  final PaymentRepository? paymentRepository;
  final ClinicSettingsRepository? clinicSettingsRepository;
  final UserManagementRepository? userManagementRepository;
  final String initialRoute;

  const DentalApp({
    super.key,
    this.authRepository,
    this.passwordRecoveryRepository,
    this.clinicOnboardingRepository,
    this.verificationRepository,
    this.onboardingStatusRepository,
    this.subscriptionRepository,
    this.paymentRepository,
    this.clinicSettingsRepository,
    this.userManagementRepository,
    this.initialRoute = RouteNames.login,
  });

  @override
  Widget build(BuildContext context) {
    // Instantiate default repositories if not injected
    final authRepo = authRepository ?? MockAuthRepository();
    final pwRepo = passwordRecoveryRepository ?? MockPasswordRecoveryRepository();
    final onboardingRepo = clinicOnboardingRepository ?? MockClinicOnboardingRepository();
    final verificationRepo = verificationRepository ?? MockVerificationRepository();
    final onboardingStatusRepo = onboardingStatusRepository ?? MockOnboardingStatusRepository();
    final subscriptionRepo = subscriptionRepository ?? MockSubscriptionRepository();
    final paymentRepo = paymentRepository ?? MockPaymentRepository();
    final settingsRepo = clinicSettingsRepository ?? MockClinicSettingsRepository();
    final userManagementRepo = userManagementRepository ?? MockUserManagementRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<PasswordRecoveryRepository>.value(value: pwRepo),
        RepositoryProvider<ClinicOnboardingRepository>.value(value: onboardingRepo),
        RepositoryProvider<VerificationRepository>.value(value: verificationRepo),
        RepositoryProvider<OnboardingStatusRepository>.value(value: onboardingStatusRepo),
        RepositoryProvider<SubscriptionRepository>.value(value: subscriptionRepo),
        RepositoryProvider<PaymentRepository>.value(value: paymentRepo),
        RepositoryProvider<ClinicSettingsRepository>.value(value: settingsRepo),
        RepositoryProvider<UserManagementRepository>.value(value: userManagementRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (ctx) => AuthBloc(authRepository: authRepo),
          ),
          BlocProvider<PasswordRecoveryBloc>(
            create: (ctx) => PasswordRecoveryBloc(repository: pwRepo),
          ),
          BlocProvider<ClinicOnboardingBloc>(
            create: (ctx) => ClinicOnboardingBloc(repository: onboardingRepo),
          ),
          BlocProvider<VerificationBloc>(
            create: (ctx) => VerificationBloc(repository: verificationRepo),
          ),
          BlocProvider<OnboardingStatusBloc>(
            create: (ctx) => OnboardingStatusBloc(repository: onboardingStatusRepo),
          ),
          BlocProvider<SubscriptionBloc>(
            create: (ctx) => SubscriptionBloc(repository: subscriptionRepo),
          ),
          BlocProvider<PaymentBloc>(
            create: (ctx) => PaymentBloc(
              paymentRepository: paymentRepo,
              subscriptionRepository: subscriptionRepo,
            ),
          ),
          BlocProvider<ClinicSettingsBloc>(
            create: (ctx) => ClinicSettingsBloc(repository: settingsRepo),
          ),
          BlocProvider<UserManagementBloc>(
            create: (ctx) => UserManagementBloc(repository: userManagementRepo),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
