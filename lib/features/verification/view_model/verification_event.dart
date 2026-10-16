import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class CheckEmailVerificationStatus extends VerificationEvent {
  final String email;

  const CheckEmailVerificationStatus(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyOtpSubmitted extends VerificationEvent {
  final String email;
  final String otp;

  const VerifyOtpSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResendVerificationEmailRequested extends VerificationEvent {
  final String email;

  const ResendVerificationEmailRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ResendVerificationOtpRequested extends VerificationEvent {
  final String email;

  const ResendVerificationOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class VerificationCooldownTicked extends VerificationEvent {
  final int secondsRemaining;

  const VerificationCooldownTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}
