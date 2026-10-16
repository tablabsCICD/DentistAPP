import '../../../core/errors/app_exception.dart';

abstract class PasswordRecoveryRepository {
  Future<void> requestPasswordReset({required String email});
  Future<String> verifyResetCode({required String email, required String code});
  Future<void> resendResetCode({required String email});
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

class MockPasswordRecoveryRepository implements PasswordRecoveryRepository {
  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.contains('notfound@')) {
      throw const ValidationException('No clinic account found with this email address.');
    }
  }

  @override
  Future<String> verifyResetCode({required String email, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (code == '000000') {
      throw const ExpiredTokenException('This reset code has expired. Please request a new code.');
    }
    if (code != '123456') {
      throw const InvalidTokenException('The 6-digit code is incorrect. Try 123456 for demo.');
    }
    return 'demo-valid-reset-token-xyz789';
  }

  @override
  Future<void> resendResetCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (resetToken.isEmpty) {
      throw const ExpiredTokenException('Reset session has expired. Please start again.');
    }
  }
}
