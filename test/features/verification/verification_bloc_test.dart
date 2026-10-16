import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/verification/data/verification_repository.dart';
import 'package:ai_dental_app/features/verification/view_model/verification_bloc.dart';
import 'package:ai_dental_app/features/verification/view_model/verification_event.dart';
import 'package:ai_dental_app/features/verification/view_model/verification_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerificationBloc Tests', () {
    late MockVerificationRepository mockRepo;

    setUp(() {
      mockRepo = MockVerificationRepository();
    });

    blocTest<VerificationBloc, VerificationState>(
      'verifies email status successfully when link check is dispatched',
      build: () => VerificationBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(const CheckEmailVerificationStatus('contact@apexdental.com')),
      expect: () => [
        const VerificationState(status: Status.loading),
        predicate<VerificationState>((state) {
          return state.status == Status.success && state.isVerified == true;
        }),
      ],
    );

    blocTest<VerificationBloc, VerificationState>(
      'verifies OTP code 123456 successfully',
      build: () => VerificationBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(const VerifyOtpSubmitted(email: 'contact@apexdental.com', otp: '123456')),
      expect: () => [
        const VerificationState(status: Status.loading),
        predicate<VerificationState>((state) {
          return state.status == Status.success && state.isVerified == true;
        }),
      ],
    );

    blocTest<VerificationBloc, VerificationState>(
      'emits error state on invalid OTP',
      build: () => VerificationBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(const VerifyOtpSubmitted(email: 'contact@apexdental.com', otp: '999999')),
      expect: () => [
        const VerificationState(status: Status.loading),
        predicate<VerificationState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('Incorrect verification code');
        }),
      ],
    );
  });
}
