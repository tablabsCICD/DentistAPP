import 'package:equatable/equatable.dart';
import '../../../shared/models/user_model.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamMembersRequested extends UserManagementEvent {}

class SearchQueryChanged extends UserManagementEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class InviteUserSubmitted extends UserManagementEvent {
  final UserModel currentUser;
  final String email;
  final UserRole role;
  final String firstName;
  final String lastName;

  const InviteUserSubmitted({
    required this.currentUser,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [currentUser, email, role, firstName, lastName];
}

class ToggleUserStatusRequested extends UserManagementEvent {
  final UserModel currentUser;
  final String userId;
  final UserStatus newStatus;

  const ToggleUserStatusRequested({
    required this.currentUser,
    required this.userId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [currentUser, userId, newStatus];
}

class ChangeUserRoleRequested extends UserManagementEvent {
  final UserModel currentUser;
  final String userId;
  final UserRole newRole;

  const ChangeUserRoleRequested({
    required this.currentUser,
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [currentUser, userId, newRole];
}
