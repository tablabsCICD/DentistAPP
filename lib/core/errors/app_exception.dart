/// Base application exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failure. Please check your internet.'])
      : super(code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([super.message = 'Invalid email or password. Please try again.'])
      : super(code: 'INVALID_CREDENTIALS');
}

class UserBlockedException extends AuthException {
  const UserBlockedException([super.message = 'This account or clinic is currently blocked. Contact support.'])
      : super(code: 'USER_BLOCKED');
}

class ExpiredTokenException extends AppException {
  const ExpiredTokenException([super.message = 'The verification code or token has expired. Please request a new one.'])
      : super(code: 'EXPIRED_TOKEN');
}

class InvalidTokenException extends AppException {
  const InvalidTokenException([super.message = 'The verification code entered is incorrect.'])
      : super(code: 'INVALID_TOKEN');
}

class PaymentException extends AppException {
  const PaymentException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'You do not have permission to perform this action.'])
      : super(code: 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.'])
      : super(code: 'NOT_FOUND');
}

class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred. Please try again later.'])
      : super(code: 'SERVER_ERROR');
}
