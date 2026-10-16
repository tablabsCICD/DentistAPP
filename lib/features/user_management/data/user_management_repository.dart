import '../../../core/errors/app_exception.dart';
import '../../../shared/models/user_model.dart';

abstract class UserManagementRepository {
  Future<List<UserModel>> getTeamMembers();
  Future<UserModel> inviteUser({
    required UserModel currentUser,
    required String email,
    required UserRole role,
    required String firstName,
    required String lastName,
  });
  Future<UserModel> updateUserStatus({
    required UserModel currentUser,
    required String userId,
    required UserStatus status,
  });
  Future<UserModel> updateUserRole({
    required UserModel currentUser,
    required String userId,
    required UserRole newRole,
  });
}

class MockUserManagementRepository implements UserManagementRepository {
  final List<UserModel> _users = [
    UserModel(
      id: 'usr-01',
      email: 'elena.rostova@apexdental.com',
      firstName: 'Elena',
      lastName: 'Rostova',
      phone: '+91 98765 43210',
      role: UserRole.administrator,
      status: UserStatus.active,
      clinicId: 'cln-01',
      permissions: UserPermissions.fromRole(UserRole.administrator),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    UserModel(
      id: 'usr-02',
      email: 'marcus.vance@apexdental.com',
      firstName: 'Marcus',
      lastName: 'Vance',
      phone: '+91 98765 43211',
      role: UserRole.dentist,
      status: UserStatus.active,
      clinicId: 'cln-01',
      permissions: UserPermissions.fromRole(UserRole.dentist),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserModel(
      id: 'usr-03',
      email: 'sarah.jenkins@apexdental.com',
      firstName: 'Sarah',
      lastName: 'Jenkins',
      phone: '+91 98765 43212',
      role: UserRole.staff,
      status: UserStatus.active,
      clinicId: 'cln-01',
      permissions: UserPermissions.fromRole(UserRole.staff),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserModel(
      id: 'usr-04',
      email: 'arjun.patel@apexdental.com',
      firstName: 'Arjun',
      lastName: 'Patel',
      phone: '+91 98765 43213',
      role: UserRole.dentist,
      status: UserStatus.inactive,
      clinicId: 'cln-01',
      permissions: UserPermissions.fromRole(UserRole.dentist),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 'usr-05',
      email: 'priya.sharma@apexdental.com',
      firstName: 'Priya',
      lastName: 'Sharma',
      phone: '+91 98765 43214',
      role: UserRole.staff,
      status: UserStatus.invited,
      clinicId: 'cln-01',
      permissions: UserPermissions.fromRole(UserRole.staff),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<UserModel>> getTeamMembers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_users);
  }

  @override
  Future<UserModel> inviteUser({
    required UserModel currentUser,
    required String email,
    required UserRole role,
    required String firstName,
    required String lastName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!currentUser.permissions.canInviteUsers) {
      throw const UnauthorizedException('You do not have permission to invite new team members.');
    }

    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw const ValidationException('A user with this email address is already part of the clinic.');
    }

    final newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      status: UserStatus.invited,
      clinicId: currentUser.clinicId ?? 'cln-01',
      permissions: UserPermissions.fromRole(role),
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    return newUser;
  }

  @override
  Future<UserModel> updateUserStatus({
    required UserModel currentUser,
    required String userId,
    required UserStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!currentUser.permissions.canActivateUsers && status == UserStatus.active) {
      throw const UnauthorizedException('You do not have permission to activate users.');
    }
    if (!currentUser.permissions.canDeactivateUsers && status == UserStatus.inactive) {
      throw const UnauthorizedException('You do not have permission to deactivate users.');
    }

    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw const ValidationException('User not found.');
    }

    final updated = _users[index].copyWith(status: status);
    _users[index] = updated;
    return updated;
  }

  @override
  Future<UserModel> updateUserRole({
    required UserModel currentUser,
    required String userId,
    required UserRole newRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!currentUser.permissions.canChangeUserRole) {
      throw const UnauthorizedException('You do not have permission to alter user roles.');
    }

    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw const ValidationException('User not found.');
    }

    final updated = _users[index].copyWith(
      role: newRole,
      permissions: UserPermissions.fromRole(newRole),
    );
    _users[index] = updated;
    return updated;
  }
}
