import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/user_model.dart';

class AuthState extends Equatable {
  final Status status;
  final UserModel? user;
  final ClinicDetails? clinic;
  final CurrentSubscription? subscription;
  final String? errorMessage;
  final String? nextRoute;

  const AuthState({
    this.status = Status.idle,
    this.user,
    this.clinic,
    this.subscription,
    this.errorMessage,
    this.nextRoute,
  });

  bool get isLoading => status == Status.loading;
  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Status? status,
    UserModel? user,
    ClinicDetails? clinic,
    CurrentSubscription? subscription,
    String? errorMessage,
    String? nextRoute,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      clinic: clinic ?? this.clinic,
      subscription: subscription ?? this.subscription,
      errorMessage: errorMessage,
      nextRoute: nextRoute ?? this.nextRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        clinic,
        subscription,
        errorMessage,
        nextRoute,
      ];
}
