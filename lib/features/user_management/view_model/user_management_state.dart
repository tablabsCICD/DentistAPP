import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/user_model.dart';

class UserManagementState extends Equatable {
  final Status status;
  final List<UserModel> users;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;
  final bool isInviteSuccess;

  const UserManagementState({
    this.status = Status.idle,
    this.users = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
    this.isInviteSuccess = false,
  });

  bool get isLoading => status == Status.loading;

  List<UserModel> get filteredUsers {
    if (searchQuery.trim().isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users.where((u) {
      return u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.displayName.toLowerCase().contains(q);
    }).toList();
  }

  UserManagementState copyWith({
    Status? status,
    List<UserModel>? users,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool? isInviteSuccess,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isInviteSuccess: isInviteSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        searchQuery,
        errorMessage,
        successMessage,
        isInviteSuccess,
      ];
}
