import '../../../core/errors/app_exception.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    UserRole? preferredRole,
  });

  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<ClinicDetails?> getCurrentClinic();
  Future<CurrentSubscription?> getCurrentSubscription();
}

class AuthResult {
  final UserModel user;
  final ClinicDetails? clinic;
  final CurrentSubscription? subscription;

  const AuthResult({
    required this.user,
    this.clinic,
    this.subscription,
  });
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  ClinicDetails? _currentClinic;
  CurrentSubscription? _currentSubscription;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    UserRole? preferredRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();

    // Check invalid password
    if (password != 'Password123!') {
      throw const InvalidCredentialsException('Incorrect email or password. Hint: Use Password123!');
    }

    if (normalizedEmail == 'blocked@clinic.com') {
      throw const UserBlockedException('Your clinic account has been suspended. Please contact support.');
    }

    // Role-specific demo users
    if (normalizedEmail == 'staff@clinic.com') {
      _currentUser = UserModel(
        id: 'usr-staff-01',
        email: 'staff@clinic.com',
        firstName: 'Sarah',
        lastName: 'Jenkins',
        phone: '+91 98765 11111',
        role: UserRole.staff,
        status: UserStatus.active,
        clinicId: 'cln-01',
        permissions: UserPermissions.fromRole(UserRole.staff),
      );
      _currentClinic = const ClinicDetails(
        id: 'cln-01',
        name: 'Apex Dental Care',
        clinicType: 'Multi-Speciality Practice',
        address: '42 Medical Enclave, MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Sarah Jenkins',
        primaryPhone: '+91 98765 11111',
        primaryEmail: 'staff@clinic.com',
        status: ClinicStatus.active,
        onboardingStatus: InternalOnboardingStatus.complete,
        isEmailVerified: true,
        isSubscriptionActive: true,
      );
      _currentSubscription = CurrentSubscription(
        id: 'sub-01',
        plan: const SubscriptionPlan(
          id: 'plan-pro',
          name: 'Professional Clinic',
          monthlyPrice: 3999,
          features: ['Unlimited AI Scans', 'Up to 10 Dentists', 'Priority Support'],
          limits: {'Dentists': 10, 'Monthly Scans': 'Unlimited'},
        ),
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        renewalDate: DateTime.now().add(const Duration(days: 30)),
      );
    } else if (normalizedEmail == 'newadmin@clinic.com') {
      _currentUser = UserModel(
        id: 'usr-new-01',
        email: 'newadmin@clinic.com',
        firstName: 'Alex',
        lastName: 'Morgan',
        phone: '+91 98765 22222',
        role: UserRole.administrator,
        status: UserStatus.active,
        clinicId: null,
        permissions: UserPermissions.fromRole(UserRole.administrator),
      );
      _currentClinic = null;
      _currentSubscription = null;
    } else if (normalizedEmail == 'unverified@clinic.com') {
      _currentUser = UserModel(
        id: 'usr-unv-01',
        email: 'unverified@clinic.com',
        firstName: 'David',
        lastName: 'Miller',
        role: UserRole.administrator,
        status: UserStatus.active,
        clinicId: 'cln-unv',
        permissions: UserPermissions.fromRole(UserRole.administrator),
      );
      _currentClinic = const ClinicDetails(
        id: 'cln-unv',
        name: 'Metro Smiles Clinic',
        clinicType: 'General Dentistry',
        address: '101 Park Street',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        postalCode: '400001',
        primaryContactName: 'David Miller',
        primaryPhone: '+91 98765 33333',
        primaryEmail: 'unverified@clinic.com',
        status: ClinicStatus.pending,
        onboardingStatus: InternalOnboardingStatus.verificationPending,
        isEmailVerified: false,
        isSubscriptionActive: false,
      );
      _currentSubscription = null;
    } else {
      // Default: Dentist / Admin (dentist@clinic.com or admin@clinic.com or any email)
      final role = preferredRole ?? (normalizedEmail.contains('staff') ? UserRole.staff : UserRole.dentist);
      _currentUser = UserModel(
        id: 'usr-dentist-01',
        email: normalizedEmail,
        firstName: 'Elena',
        lastName: 'Rostova',
        phone: '+91 98765 43210',
        role: role,
        status: UserStatus.active,
        clinicId: 'cln-01',
        permissions: UserPermissions.fromRole(role),
      );
      _currentClinic = const ClinicDetails(
        id: 'cln-01',
        name: 'Apex Dental Care',
        clinicType: 'Orthodontics & Aesthetic Center',
        address: '42 Medical Enclave, MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena Rostova',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'dentist@clinic.com',
        status: ClinicStatus.active,
        onboardingStatus: InternalOnboardingStatus.complete,
        isEmailVerified: true,
        isSubscriptionActive: true,
      );
      _currentSubscription = CurrentSubscription(
        id: 'sub-01',
        plan: const SubscriptionPlan(
          id: 'plan-pro',
          name: 'Professional Clinic',
          monthlyPrice: 3999,
          features: ['Unlimited AI Diagnostics', 'Multi-user access', 'Cloud storage'],
          limits: {'Users': 15, 'Patients': 'Unlimited'},
        ),
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        renewalDate: DateTime.now().add(const Duration(days: 15)),
      );
    }

    return AuthResult(
      user: _currentUser!,
      clinic: _currentClinic,
      subscription: _currentSubscription,
    );
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _currentClinic = null;
    _currentSubscription = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<ClinicDetails?> getCurrentClinic() async => _currentClinic;

  @override
  Future<CurrentSubscription?> getCurrentSubscription() async => _currentSubscription;
}
