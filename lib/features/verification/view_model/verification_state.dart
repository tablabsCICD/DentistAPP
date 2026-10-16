import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';

class VerificationState extends Equatable {
  final Status status;
  final bool isVerified;
  final String? errorMessage;
  final String? successMessage;
  final int resendCooldownSeconds;

  const VerificationState({
    this.status = Status.idle,
    this.isVerified = false,
    this.errorMessage,
    this.successMessage,
    this.resendCooldownSeconds = 0,
  });

  bool get isLoading => status == Status.loading;
  bool get canResend => resendCooldownSeconds == 0;

  VerificationState copyWith({
    Status? status,
    bool? isVerified,
    String? errorMessage,
    String? successMessage,
    int? resendCooldownSeconds,
  }) {
    return VerificationState(
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage,
      successMessage: successMessage,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isVerified,
        errorMessage,
        successMessage,
        resendCooldownSeconds,
      ];
}
