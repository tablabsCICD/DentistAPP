import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository _repository;
  Timer? _cooldownTimer;

  VerificationBloc({required VerificationRepository repository})
      : _repository = repository,
        super(const VerificationState()) {
    on<CheckEmailVerificationStatus>(_onCheckEmailVerificationStatus);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<ResendVerificationOtpRequested>(_onResendVerificationOtpRequested);
    on<VerificationCooldownTicked>(_onVerificationCooldownTicked);
  }

  Future<void> _onCheckEmailVerificationStatus(
    CheckEmailVerificationStatus event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final verified = await _repository.checkEmailLinkStatus(email: event.email);
      if (verified) {
        emit(state.copyWith(
          status: Status.success,
          isVerified: true,
          successMessage: 'Email successfully verified!',
        ));
      } else {
        emit(state.copyWith(
          status: Status.idle,
          isVerified: false,
          errorMessage: 'Email is not yet verified. Please click the link sent to your inbox.',
        ));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.verifyOtp(email: event.email, otp: event.otp);
      emit(state.copyWith(
        status: Status.success,
        isVerified: true,
        successMessage: 'Account verified successfully!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Invalid code. Please try again.',
      ));
    }
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<VerificationState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: Status.loading, errorMessage: null));
    try {
      await _repository.resendVerificationEmail(email: event.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'A new verification link has been sent to your email.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }

  Future<void> _onResendVerificationOtpRequested(
    ResendVerificationOtpRequested event,
    Emitter<VerificationState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: Status.loading, errorMessage: null));
    try {
      await _repository.resendVerificationOtp(email: event.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'A fresh 6-digit OTP code has been dispatched.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }

  void _onVerificationCooldownTicked(VerificationCooldownTicked event, Emitter<VerificationState> emit) {
    emit(state.copyWith(resendCooldownSeconds: event.secondsRemaining));
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    int secondsRemaining = AppConstants.otpCooldownSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining--;
      if (secondsRemaining <= 0) {
        timer.cancel();
        add(const VerificationCooldownTicked(0));
      } else {
        add(VerificationCooldownTicked(secondsRemaining));
      }
    });
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
