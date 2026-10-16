import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';

enum PasswordRecoveryStep {
  forgotPassword,
  resetCode,
  newPassword,
  success,
}

class PasswordRecoveryState extends Equatable {
  final Status status;
  final PasswordRecoveryStep step;
  final String email;
  final String? resetToken;
  final String? errorMessage;
  final String? successMessage;
  final int resendCooldownSeconds;

  const PasswordRecoveryState({
    this.status = Status.idle,
    this.step = PasswordRecoveryStep.forgotPassword,
    this.email = '',
    this.resetToken,
    this.errorMessage,
    this.successMessage,
    this.resendCooldownSeconds = 0,
  });

  bool get isLoading => status == Status.loading;
  bool get canResend => resendCooldownSeconds == 0;

  PasswordRecoveryState copyWith({
    Status? status,
    PasswordRecoveryStep? step,
    String? email,
    String? resetToken,
    String? errorMessage,
    String? successMessage,
    int? resendCooldownSeconds,
  }) {
    return PasswordRecoveryState(
      status: status ?? this.status,
      step: step ?? this.step,
      email: email ?? this.email,
      resetToken: resetToken ?? this.resetToken,
      errorMessage: errorMessage,
      successMessage: successMessage,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        step,
        email,
        resetToken,
        errorMessage,
        successMessage,
        resendCooldownSeconds,
      ];
}
