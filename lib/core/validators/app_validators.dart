/// Centralized validation utilities for the Dental Application
class AppValidators {
  AppValidators._();

  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static final RegExp _phoneRegExp = RegExp(
    r"^\+?[0-9]{7,15}$",
  );

  static final RegExp _otpRegExp = RegExp(
    r"^[0-9]{6}$",
  );

  /// Validates standard required fields
  static String? requiredField(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email address format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates password confirmation match
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final sanitized = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegExp.hasMatch(sanitized)) {
      return 'Please enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  /// Validates 6-digit OTP code
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    final trimmed = value.trim();
    if (!_otpRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid 6-digit code';
    }
    return null;
  }

  /// Validates clinic name
  static String? clinicName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Clinic name is required';
    }
    if (value.trim().length < 2) {
      return 'Clinic name must be at least 2 characters';
    }
    return null;
  }

  /// Validates administrator full or first/last name
  static String? administratorName(String? value, [String part = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$part is required';
    }
    if (value.trim().length < 2) {
      return '$part must be at least 2 characters';
    }
    return null;
  }

  /// Validates postal code
  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    if (value.trim().length < 3 || value.trim().length > 12) {
      return 'Please enter a valid postal/zip code';
    }
    return null;
  }

  /// Validates timezone selection
  static String? timezone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a valid timezone';
    }
    return null;
  }

  /// Validates role selection
  static String? role(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a role';
    }
    return null;
  }

  /// Validates website (optional but format checked if provided)
  static String? website(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://') && !trimmed.contains('.')) {
      return 'Please enter a valid URL (e.g., https://dentalclinic.com)';
    }
    return null;
  }
}
