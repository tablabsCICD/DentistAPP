/// Core application constants
class AppConstants {
  AppConstants._();

  static const String appName = 'DentFlow AI';
  static const String appTagline = 'Intelligent Dental Practice Management & Diagnostics';
  static const String appVersion = '1.0.0';

  // Timeouts & Durations
  static const int apiTimeoutSeconds = 30;
  static const int otpCooldownSeconds = 60;
  static const int otpLength = 6;
  static const int minPasswordLength = 8;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
}
