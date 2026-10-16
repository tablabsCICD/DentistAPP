import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/user_model.dart';
import '../data/user_management_repository.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserManagementRepository _repository;

  UserManagementBloc({required UserManagementRepository repository})
      : _repository = repository,
        super(const UserManagementState()) {
    on<LoadTeamMembersRequested>(_onLoadTeamMembersRequested);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<InviteUserSubmitted>(_onInviteUserSubmitted);
    on<ToggleUserStatusRequested>(_onToggleUserStatusRequested);
    on<ChangeUserRoleRequested>(_onChangeUserRoleRequested);
  }

  Future<void> _onLoadTeamMembersRequested(
    LoadTeamMembersRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final members = await _repository.getTeamMembers();
      emit(state.copyWith(
        status: Status.success,
        users: members,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to retrieve team directory.'));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<UserManagementState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onInviteUserSubmitted(
    InviteUserSubmitted event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, isInviteSuccess: false));

    try {
      final newUser = await _repository.inviteUser(
        currentUser: event.currentUser,
        email: event.email,
        role: event.role,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      final updatedList = List<UserModel>.from(state.users)..add(newUser);

      emit(state.copyWith(
        status: Status.success,
        users: updatedList,
        isInviteSuccess: true,
        successMessage: 'Invitation dispatched to ${newUser.email} successfully!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to send invitation. Please try again.'));
    }
  }

  Future<void> _onToggleUserStatusRequested(
    ToggleUserStatusRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final updated = await _repository.updateUserStatus(
        currentUser: event.currentUser,
        userId: event.userId,
        status: event.newStatus,
      );

      final updatedList = state.users.map((u) => u.id == updated.id ? updated : u).toList();

      emit(state.copyWith(
        status: Status.success,
        users: updatedList,
        successMessage: 'User status updated to ${updated.status.displayName}.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Unable to modify user status.'));
    }
  }

  Future<void> _onChangeUserRoleRequested(
    ChangeUserRoleRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final updated = await _repository.updateUserRole(
        currentUser: event.currentUser,
        userId: event.userId,
        newRole: event.newRole,
      );

      final updatedList = state.users.map((u) => u.id == updated.id ? updated : u).toList();

      emit(state.copyWith(
        status: Status.success,
        users: updatedList,
        successMessage: 'User role changed to ${updated.role.displayName}.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Unable to update user permissions.'));
    }
  }
}
