import 'package:equatable/equatable.dart';

enum UserRole {
  staff,
  dentist,
  administrator,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.staff:
        return 'Clinic Staff';
      case UserRole.dentist:
        return 'Dentist';
      case UserRole.administrator:
        return 'Clinic Administrator';
    }
  }

  String get code {
    switch (this) {
      case UserRole.staff:
        return 'STAFF';
      case UserRole.dentist:
        return 'DENTIST';
      case UserRole.administrator:
        return 'ADMINISTRATOR';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'STAFF':
        return UserRole.staff;
      case 'DENTIST':
        return UserRole.dentist;
      case 'ADMINISTRATOR':
      case 'ADMIN':
        return UserRole.administrator;
      default:
        return UserRole.staff;
    }
  }
}

enum UserStatus {
  active,
  inactive,
  invited,
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.invited:
        return 'Invited';
    }
  }
}

class UserPermissions extends Equatable {
  final bool canInviteUsers;
  final bool canActivateUsers;
  final bool canDeactivateUsers;
  final bool canChangeUserRole;
  final bool canEditClinicSettings;
  final bool canManageSubscription;

  const UserPermissions({
    this.canInviteUsers = false,
    this.canActivateUsers = false,
    this.canDeactivateUsers = false,
    this.canChangeUserRole = false,
    this.canEditClinicSettings = false,
    this.canManageSubscription = false,
  });

  factory UserPermissions.fromRole(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return const UserPermissions(
          canInviteUsers: true,
          canActivateUsers: true,
          canDeactivateUsers: true,
          canChangeUserRole: true,
          canEditClinicSettings: true,
          canManageSubscription: true,
        );
      case UserRole.dentist:
        return const UserPermissions(
          canInviteUsers: false,
          canActivateUsers: false,
          canDeactivateUsers: false,
          canChangeUserRole: false,
          canEditClinicSettings: false,
          canManageSubscription: false,
        );
      case UserRole.staff:
        return const UserPermissions(
          canInviteUsers: false,
          canActivateUsers: false,
          canDeactivateUsers: false,
          canChangeUserRole: false,
          canEditClinicSettings: false,
          canManageSubscription: false,
        );
    }
  }

  @override
  List<Object?> get props => [
        canInviteUsers,
        canActivateUsers,
        canDeactivateUsers,
        canChangeUserRole,
        canEditClinicSettings,
        canManageSubscription,
      ];
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final UserStatus status;
  final String? clinicId;
  final UserPermissions permissions;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.status = UserStatus.active,
    this.clinicId,
    required this.permissions,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    UserStatus? status,
    String? clinicId,
    UserPermissions? permissions,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      clinicId: clinicId ?? this.clinicId,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        role,
        status,
        clinicId,
        permissions,
        createdAt,
      ];
}
