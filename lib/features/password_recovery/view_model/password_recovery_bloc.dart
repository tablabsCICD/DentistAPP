import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/password_recovery_repository.dart';
import 'password_recovery_event.dart';
import 'password_recovery_state.dart';

class PasswordRecoveryBloc extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  final PasswordRecoveryRepository _repository;
  Timer? _cooldownTimer;

  PasswordRecoveryBloc({required PasswordRecoveryRepository repository})
      : _repository = repository,
        super(const PasswordRecoveryState()) {
    on<RequestResetSubmitted>(_onRequestResetSubmitted);
    on<ResetCodeSubmitted>(_onResetCodeSubmitted);
    on<ResendResetCodeRequested>(_onResendResetCodeRequested);
    on<NewPasswordSubmitted>(_onNewPasswordSubmitted);
    on<PasswordCooldownTicked>(_onPasswordCooldownTicked);
    on<ResetFlowReset>(_onResetFlowReset);
  }

  Future<void> _onRequestResetSubmitted(
    RequestResetSubmitted event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.requestPasswordReset(email: event.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.success,
        step: PasswordRecoveryStep.resetCode,
        email: event.email,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unable to process reset request. Please try again.',
      ));
    }
  }

  Future<void> _onResetCodeSubmitted(
    ResetCodeSubmitted event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final token = await _repository.verifyResetCode(
        email: state.email,
        code: event.code,
      );
      emit(state.copyWith(
        status: Status.success,
        step: PasswordRecoveryStep.newPassword,
        resetToken: token,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Invalid verification code. Please try again.',
      ));
    }
  }

  Future<void> _onResendResetCodeRequested(
    ResendResetCodeRequested event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: Status.loading, errorMessage: null));
    try {
      await _repository.resendResetCode(email: state.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'A new 6-digit code has been sent to your email.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> _onNewPasswordSubmitted(
    NewPasswordSubmitted event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.resetPassword(
        resetToken: state.resetToken ?? '',
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: Status.success,
        step: PasswordRecoveryStep.success,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Failed to update password. Please try again.',
      ));
    }
  }

  void _onPasswordCooldownTicked(PasswordCooldownTicked event, Emitter<PasswordRecoveryState> emit) {
    emit(state.copyWith(resendCooldownSeconds: event.secondsRemaining));
  }

  void _onResetFlowReset(ResetFlowReset event, Emitter<PasswordRecoveryState> emit) {
    _cooldownTimer?.cancel();
    emit(const PasswordRecoveryState());
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    int secondsRemaining = AppConstants.otpCooldownSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining--;
      if (secondsRemaining <= 0) {
        timer.cancel();
        add(const PasswordCooldownTicked(0));
      } else {
        add(PasswordCooldownTicked(secondsRemaining));
      }
    });
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
