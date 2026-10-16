import '../../../core/errors/app_exception.dart';

abstract class VerificationRepository {
  Future<bool> checkEmailLinkStatus({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resendVerificationEmail({required String email});
  Future<void> resendVerificationOtp({required String email});
}

class MockVerificationRepository implements VerificationRepository {
  @override
  Future<bool> checkEmailLinkStatus({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp == '000000') {
      throw const ExpiredTokenException('This verification code has expired. Please request a new one.');
    }
    if (otp != '123456') {
      throw const InvalidTokenException('Incorrect verification code. Hint: Use 123456 for demo.');
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
