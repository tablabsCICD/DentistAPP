import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_guards.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthSessionRequested>(_onCheckAuthSessionRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
        preferredRole: event.selectedRole,
      );

      final nextDestination = RouteGuards.resolvePostLoginDestination(
        user: result.user,
        clinic: result.clinic,
        subscription: result.subscription,
      );

      emit(state.copyWith(
        status: Status.success,
        user: result.user,
        clinic: result.clinic,
        subscription: result.subscription,
        nextRoute: nextDestination,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'An unexpected error occurred during login. Please try again.',
      ));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthState());
  }

  Future<void> _onCheckAuthSessionRequested(CheckAuthSessionRequested event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      final clinic = await _authRepository.getCurrentClinic();
      final subscription = await _authRepository.getCurrentSubscription();
      final next = RouteGuards.resolvePostLoginDestination(
        user: user,
        clinic: clinic,
        subscription: subscription,
      );
      emit(state.copyWith(
        status: Status.success,
        user: user,
        clinic: clinic,
        subscription: subscription,
        nextRoute: next,
      ));
    }
  }
}
