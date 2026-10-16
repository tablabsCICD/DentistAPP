/// Centralized route names for navigation
class RouteNames {
  RouteNames._();

  static const String initial = '/';
  static const String login = '/login';

  // Password Recovery Flow
  static const String forgotPassword = '/forgot-password';
  static const String resetCode = '/reset-password';
  static const String newPassword = '/new-password';
  static const String passwordResetSuccess = '/password-reset-success';

  // Clinic Onboarding & Verification
  static const String clinicOnboarding = '/clinic-onboarding';
  static const String emailVerification = '/email-verification';
  static const String otpVerification = '/otp-verification';
  static const String onboardingStatus = '/onboarding-status';

  // Subscription & Payment
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionCheckout = '/subscription/checkout';
  static const String subscriptionStatus = '/subscription/status';

  // Settings & Management
  static const String clinicSettings = '/clinic-settings';
  static const String users = '/users';
  static const String inviteUser = '/users/invite';

  // Patient Clinical Management
  static const String patients = '/patients';
  static const String registerPatient = '/patients/register';
  static const String patientDetails = '/patients/details';
  static const String editPatient = '/patients/edit';
}
