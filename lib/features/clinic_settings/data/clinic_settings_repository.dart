import '../../../core/errors/app_exception.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/user_model.dart';

abstract class ClinicSettingsRepository {
  Future<ClinicDetails> getClinicSettings();
  Future<ClinicDetails> updateClinicProfile({
    required UserModel currentUser,
    required ClinicDetails updatedClinic,
  });
  Future<OperationalSettings> updateOperationalSettings({
    required UserModel currentUser,
    required OperationalSettings updatedSettings,
  });
}

class MockClinicSettingsRepository implements ClinicSettingsRepository {
  ClinicDetails _clinic = const ClinicDetails(
    id: 'cln-01',
    name: 'Apex Dental Care',
    clinicType: 'Multi-Speciality Practice',
    address: '42 Medical Enclave, MG Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    postalCode: '560001',
    website: 'https://apexdental.com',
    primaryContactName: 'Dr. Elena Rostova',
    primaryPhone: '+91 98765 43210',
    primaryEmail: 'contact@apexdental.com',
    status: ClinicStatus.active,
    onboardingStatus: InternalOnboardingStatus.complete,
    isEmailVerified: true,
    isSubscriptionActive: true,
    operationalSettings: OperationalSettings(
      timezone: 'UTC+05:30 (India Standard Time)',
      openingTime: '09:00',
      closingTime: '19:00',
      maxAiScansPerDay: 150,
      enableAutoAppointmentReminders: true,
      allowStaffDataExport: false,
    ),
  );

  @override
  Future<ClinicDetails> getClinicSettings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _clinic;
  }

  @override
  Future<ClinicDetails> updateClinicProfile({
    required UserModel currentUser,
    required ClinicDetails updatedClinic,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!currentUser.permissions.canEditClinicSettings) {
      throw const UnauthorizedException('Only Clinic Administrators have permission to edit clinic profile settings.');
    }

    _clinic = updatedClinic;
    return _clinic;
  }

  @override
  Future<OperationalSettings> updateOperationalSettings({
    required UserModel currentUser,
    required OperationalSettings updatedSettings,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!currentUser.permissions.canEditClinicSettings) {
      throw const UnauthorizedException('Only Clinic Administrators can modify operational clinic parameters.');
    }

    _clinic = _clinic.copyWith(operationalSettings: updatedSettings);
    return updatedSettings;
  }
}
