import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/password_recovery/data/password_recovery_repository.dart';
import 'package:ai_dental_app/features/password_recovery/view_model/password_recovery_bloc.dart';
import 'package:ai_dental_app/features/password_recovery/view_model/password_recovery_event.dart';
import 'package:ai_dental_app/features/password_recovery/view_model/password_recovery_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordRecoveryBloc Tests', () {
    late MockPasswordRecoveryRepository mockRepo;

    setUp(() {
      mockRepo = MockPasswordRecoveryRepository();
    });

    blocTest<PasswordRecoveryBloc, PasswordRecoveryState>(
      'transitions to resetCode step when valid email is submitted',
      build: () => PasswordRecoveryBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(const RequestResetSubmitted('dentist@clinic.com')),
      expect: () => [
        const PasswordRecoveryState(status: Status.loading),
        predicate<PasswordRecoveryState>((state) {
          return state.status == Status.success &&
              state.step == PasswordRecoveryStep.resetCode &&
              state.email == 'dentist@clinic.com' &&
              state.resendCooldownSeconds > 0;
        }),
      ],
    );

    blocTest<PasswordRecoveryBloc, PasswordRecoveryState>(
      'transitions to newPassword step on valid 6-digit OTP code 123456',
      build: () => PasswordRecoveryBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      seed: () => const PasswordRecoveryState(
        step: PasswordRecoveryStep.resetCode,
        email: 'dentist@clinic.com',
      ),
      act: (bloc) => bloc.add(const ResetCodeSubmitted('123456')),
      expect: () => [
        const PasswordRecoveryState(
          status: Status.loading,
          step: PasswordRecoveryStep.resetCode,
          email: 'dentist@clinic.com',
        ),
        predicate<PasswordRecoveryState>((state) {
          return state.status == Status.success &&
              state.step == PasswordRecoveryStep.newPassword &&
              state.resetToken != null;
        }),
      ],
    );

    blocTest<PasswordRecoveryBloc, PasswordRecoveryState>(
      'emits error state on expired code 000000',
      build: () => PasswordRecoveryBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      seed: () => const PasswordRecoveryState(
        step: PasswordRecoveryStep.resetCode,
        email: 'dentist@clinic.com',
      ),
      act: (bloc) => bloc.add(const ResetCodeSubmitted('000000')),
      expect: () => [
        const PasswordRecoveryState(
          status: Status.loading,
          step: PasswordRecoveryStep.resetCode,
          email: 'dentist@clinic.com',
        ),
        predicate<PasswordRecoveryState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('expired');
        }),
      ],
    );
  });
}
