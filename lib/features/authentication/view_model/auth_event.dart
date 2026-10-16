import 'package:equatable/equatable.dart';
import '../../../shared/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole selectedRole;

  const LoginRequested({
    required this.email,
    required this.password,
    required this.selectedRole,
  });

  @override
  List<Object?> get props => [email, password, selectedRole];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthSessionRequested extends AuthEvent {}
