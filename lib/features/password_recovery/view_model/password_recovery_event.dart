import 'package:equatable/equatable.dart';

abstract class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();

  @override
  List<Object?> get props => [];
}

class RequestResetSubmitted extends PasswordRecoveryEvent {
  final String email;

  const RequestResetSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetCodeSubmitted extends PasswordRecoveryEvent {
  final String code;

  const ResetCodeSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}

class ResendResetCodeRequested extends PasswordRecoveryEvent {}

class NewPasswordSubmitted extends PasswordRecoveryEvent {
  final String newPassword;

  const NewPasswordSubmitted(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

class PasswordCooldownTicked extends PasswordRecoveryEvent {
  final int secondsRemaining;

  const PasswordCooldownTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

class ResetFlowReset extends PasswordRecoveryEvent {}
