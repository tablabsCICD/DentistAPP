import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/clinic_settings/data/clinic_settings_repository.dart';
import 'package:ai_dental_app/features/clinic_settings/view_model/clinic_settings_bloc.dart';
import 'package:ai_dental_app/features/clinic_settings/view_model/clinic_settings_event.dart';
import 'package:ai_dental_app/features/clinic_settings/view_model/clinic_settings_state.dart';
import 'package:ai_dental_app/features/user_management/data/user_management_repository.dart';
import 'package:ai_dental_app/features/user_management/view_model/user_management_bloc.dart';
import 'package:ai_dental_app/features/user_management/view_model/user_management_event.dart';
import 'package:ai_dental_app/features/user_management/view_model/user_management_state.dart';
import 'package:ai_dental_app/shared/models/clinic_model.dart';
import 'package:ai_dental_app/shared/models/user_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicSettingsBloc & UserManagementBloc RBAC Tests', () {
    late MockClinicSettingsRepository mockSettingsRepo;
    late MockUserManagementRepository mockUserRepo;

    const adminUser = UserModel(
      id: 'admin-1',
      email: 'admin@clinic.com',
      firstName: 'Elena',
      lastName: 'Rostova',
      role: UserRole.administrator,
      permissions: UserPermissions(
        canEditClinicSettings: true,
        canInviteUsers: true,
        canActivateUsers: true,
        canDeactivateUsers: true,
        canChangeUserRole: true,
      ),
    );

    const staffUser = UserModel(
      id: 'staff-1',
      email: 'staff@clinic.com',
      firstName: 'Sarah',
      lastName: 'Jenkins',
      role: UserRole.staff,
      permissions: UserPermissions(
        canEditClinicSettings: false,
        canInviteUsers: false,
      ),
    );

    setUp(() {
      mockSettingsRepo = MockClinicSettingsRepository();
      mockUserRepo = MockUserManagementRepository();
    });

    blocTest<ClinicSettingsBloc, ClinicSettingsState>(
      'admin user can update clinic profile',
      build: () => ClinicSettingsBloc(repository: mockSettingsRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const UpdateClinicProfileRequested(
          currentUser: adminUser,
          updatedClinic: ClinicDetails(
            id: 'cln-01',
            name: 'Apex Dental Care - Modified',
            clinicType: 'Multi-Speciality Practice',
            address: '42 Medical Enclave',
            city: 'Bengaluru',
            state: 'Karnataka',
            country: 'India',
            postalCode: '560001',
            primaryContactName: 'Dr. Elena',
            primaryPhone: '+91 98765 43210',
            primaryEmail: 'contact@apexdental.com',
          ),
        ),
      ),
      expect: () => [
        const ClinicSettingsState(status: Status.loading),
        predicate<ClinicSettingsState>((state) {
          return state.status == Status.success &&
              state.clinic != null &&
              state.clinic!.name == 'Apex Dental Care - Modified';
        }),
      ],
    );

    blocTest<ClinicSettingsBloc, ClinicSettingsState>(
      'staff user without permission gets unauthorized error on clinic profile edit',
      build: () => ClinicSettingsBloc(repository: mockSettingsRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const UpdateClinicProfileRequested(
          currentUser: staffUser,
          updatedClinic: ClinicDetails(
            id: 'cln-01',
            name: 'Unauthorized Change',
            clinicType: 'Solo',
            address: 'MG Road',
            city: 'Bengaluru',
            state: 'Karnataka',
            country: 'India',
            postalCode: '560001',
            primaryContactName: 'Staff Sarah',
            primaryPhone: '+91 98765 11111',
            primaryEmail: 'staff@clinic.com',
          ),
        ),
      ),
      expect: () => [
        const ClinicSettingsState(status: Status.loading),
        predicate<ClinicSettingsState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('Only Clinic Administrators have permission');
        }),
      ],
    );

    blocTest<UserManagementBloc, UserManagementState>(
      'admin user can invite new team member successfully',
      build: () => UserManagementBloc(repository: mockUserRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const InviteUserSubmitted(
          currentUser: adminUser,
          email: 'newdoctor@apexdental.com',
          role: UserRole.dentist,
          firstName: 'Robert',
          lastName: 'Chen',
        ),
      ),
      expect: () => [
        const UserManagementState(status: Status.loading),
        predicate<UserManagementState>((state) {
          return state.status == Status.success &&
              state.isInviteSuccess == true &&
              state.users.any((u) => u.email == 'newdoctor@apexdental.com');
        }),
      ],
    );

    blocTest<UserManagementBloc, UserManagementState>(
      'staff user without permission fails to invite user',
      build: () => UserManagementBloc(repository: mockUserRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(
        const InviteUserSubmitted(
          currentUser: staffUser,
          email: 'unauthorized@apexdental.com',
          role: UserRole.staff,
          firstName: 'Unauthorized',
          lastName: 'User',
        ),
      ),
      expect: () => [
        const UserManagementState(status: Status.loading),
        predicate<UserManagementState>((state) {
          return state.status == Status.error &&
              state.errorMessage != null &&
              state.errorMessage!.contains('permission');
        }),
      ],
    );
  });
}
