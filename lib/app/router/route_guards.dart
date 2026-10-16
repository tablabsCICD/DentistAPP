import '../../shared/models/clinic_model.dart';
import '../../shared/models/subscription_model.dart';
import '../../shared/models/user_model.dart';
import 'route_names.dart';

/// Decision tree engine to determine post-login navigation destinations
class RouteGuards {
  RouteGuards._();

  static String resolvePostLoginDestination({
    required UserModel user,
    required ClinicDetails? clinic,
    required CurrentSubscription? subscription,
  }) {
    // 1. If no clinic has been onboarded yet
    if (clinic == null || clinic.onboardingStatus == InternalOnboardingStatus.setupIncomplete) {
      return RouteNames.clinicOnboarding;
    }

    // 2. If email is not verified
    if (!clinic.isEmailVerified || clinic.onboardingStatus == InternalOnboardingStatus.verificationPending) {
      return RouteNames.emailVerification;
    }

    // 3. If clinic is blocked
    if (clinic.status == ClinicStatus.blocked) {
      return RouteNames.onboardingStatus;
    }

    // 4. Check subscription status
    if (subscription == null ||
        subscription.status == SubscriptionStatus.pending ||
        clinic.onboardingStatus == InternalOnboardingStatus.subscriptionPending) {
      return RouteNames.subscriptionPlans;
    }

    // 5. If subscription is payment pending or failed
    if (subscription.status == SubscriptionStatus.paymentPending ||
        subscription.status == SubscriptionStatus.paymentFailed) {
      return RouteNames.onboardingStatus;
    }

    // 6. If clinic is pending final approval or review
    if (clinic.status == ClinicStatus.pending) {
      return RouteNames.onboardingStatus;
    }

    // 7. If everything is ACTIVE and ready
    if (user.role == UserRole.administrator) {
      return RouteNames.subscriptionStatus;
    } else {
      return RouteNames.clinicSettings;
    }
  }
}
