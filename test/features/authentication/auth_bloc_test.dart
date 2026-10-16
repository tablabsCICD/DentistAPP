import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/authentication/data/auth_repository.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_bloc.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_event.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_state.dart';
import 'package:ai_dental_app/shared/models/user_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc Tests', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, success] with resolved nextRoute when login credentials are correct',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'dentist@clinic.com',
          password: 'Password123!',
          selectedRole: UserRole.dentist,
        ),
      ),
      expect: () => [
        const AuthState(status: Status.loading),
        predicate<AuthState>((state) {
          return state.status == Status.success &&
              state.user != null &&
              state.user!.email == 'dentist@clinic.com' &&
              state.nextRoute != null;
        }),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when password is wrong',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'dentist@clinic.com',
          password: 'WrongPassword!',
          selectedRole: UserRole.dentist,
        ),
      ),
      expect: () => [
        const AuthState(status: Status.loading),
        predicate<AuthState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('Incorrect email or password');
        }),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when user is blocked',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'blocked@clinic.com',
          password: 'Password123!',
          selectedRole: UserRole.dentist,
        ),
      ),
      expect: () => [
        const AuthState(status: Status.loading),
        predicate<AuthState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('suspended');
        }),
      ],
    );
  });
}
