import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/subscription_model.dart';

abstract class OnboardingStatusRepository {
  Future<OnboardingStatusData> getOnboardingStatus();
}

class OnboardingStatusData {
  final ClinicDetails clinic;
  final CurrentSubscription? subscription;

  const OnboardingStatusData({
    required this.clinic,
    this.subscription,
  });
}

class MockOnboardingStatusRepository implements OnboardingStatusRepository {
  ClinicDetails _clinic = const ClinicDetails(
    id: 'cln-01',
    name: 'Apex Dental Care',
    clinicType: 'Multi-Speciality Practice',
    address: '42 Medical Enclave, MG Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    postalCode: '560001',
    primaryContactName: 'Dr. Elena Rostova',
    primaryPhone: '+91 98765 43210',
    primaryEmail: 'contact@apexdental.com',
    status: ClinicStatus.pending,
    onboardingStatus: InternalOnboardingStatus.subscriptionPending,
    isEmailVerified: true,
    isSubscriptionActive: false,
  );

  CurrentSubscription? _subscription;

  void setClinicState(ClinicDetails clinic, [CurrentSubscription? subscription]) {
    _clinic = clinic;
    _subscription = subscription;
  }

  @override
  Future<OnboardingStatusData> getOnboardingStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return OnboardingStatusData(
      clinic: _clinic,
      subscription: _subscription,
    );
  }
}
