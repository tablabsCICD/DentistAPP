import '../../../core/errors/app_exception.dart';
import '../../../shared/models/clinic_model.dart';
import '../domain/onboarding_form_data.dart';

abstract class ClinicOnboardingRepository {
  Future<ClinicDetails> submitClinicOnboarding(OnboardingFormData data);
}

class MockClinicOnboardingRepository implements ClinicOnboardingRepository {
  @override
  Future<ClinicDetails> submitClinicOnboarding(OnboardingFormData data) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (data.clinicName.toLowerCase().contains('fail')) {
      throw const ServerException('Registration failed due to a server collision. Please retry with a valid clinic name.');
    }

    return ClinicDetails(
      id: 'cln-${DateTime.now().millisecondsSinceEpoch}',
      name: data.clinicName,
      clinicType: data.clinicType,
      address: data.address,
      city: data.city,
      state: data.state,
      country: data.country,
      postalCode: data.postalCode,
      website: data.website.isNotEmpty ? data.website : null,
      primaryContactName: data.primaryContactName,
      primaryPhone: data.primaryPhone,
      primaryEmail: data.primaryEmail,
      alternatePhone: data.alternatePhone.isNotEmpty ? data.alternatePhone : null,
      status: ClinicStatus.pending,
      onboardingStatus: InternalOnboardingStatus.verificationPending,
      isEmailVerified: false,
      isSubscriptionActive: false,
    );
  }
}
