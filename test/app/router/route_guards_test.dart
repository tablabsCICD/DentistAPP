import 'package:ai_dental_app/app/router/route_guards.dart';
import 'package:ai_dental_app/app/router/route_names.dart';
import 'package:ai_dental_app/shared/models/clinic_model.dart';
import 'package:ai_dental_app/shared/models/subscription_model.dart';
import 'package:ai_dental_app/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuards Post-Login Navigation Engine Tests', () {
    const adminUser = UserModel(
      id: 'admin-1',
      email: 'admin@clinic.com',
      firstName: 'Elena',
      lastName: 'Rostova',
      role: UserRole.administrator,
      permissions: UserPermissions(canManageSubscription: true),
    );

    const staffUser = UserModel(
      id: 'staff-1',
      email: 'staff@clinic.com',
      firstName: 'Sarah',
      lastName: 'Jenkins',
      role: UserRole.staff,
      permissions: UserPermissions(),
    );

    test('navigates to clinicOnboarding if clinic is null', () {
      final route = RouteGuards.resolvePostLoginDestination(
        user: adminUser,
        clinic: null,
        subscription: null,
      );
      expect(route, RouteNames.clinicOnboarding);
    });

    test('navigates to emailVerification if email is unverified', () {
      const clinic = ClinicDetails(
        id: 'cln-1',
        name: 'Apex Dental',
        clinicType: 'General',
        address: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'contact@apex.com',
        isEmailVerified: false,
        onboardingStatus: InternalOnboardingStatus.verificationPending,
      );

      final route = RouteGuards.resolvePostLoginDestination(
        user: adminUser,
        clinic: clinic,
        subscription: null,
      );
      expect(route, RouteNames.emailVerification);
    });

    test('navigates to subscriptionPlans if subscription is pending', () {
      const clinic = ClinicDetails(
        id: 'cln-1',
        name: 'Apex Dental',
        clinicType: 'General',
        address: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'contact@apex.com',
        isEmailVerified: true,
        onboardingStatus: InternalOnboardingStatus.subscriptionPending,
      );

      final route = RouteGuards.resolvePostLoginDestination(
        user: adminUser,
        clinic: clinic,
        subscription: null,
      );
      expect(route, RouteNames.subscriptionPlans);
    });

    test('navigates to onboardingStatus if clinic is blocked', () {
      const clinic = ClinicDetails(
        id: 'cln-1',
        name: 'Apex Dental',
        clinicType: 'General',
        address: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'contact@apex.com',
        status: ClinicStatus.blocked,
        isEmailVerified: true,
        onboardingStatus: InternalOnboardingStatus.complete,
      );

      final route = RouteGuards.resolvePostLoginDestination(
        user: adminUser,
        clinic: clinic,
        subscription: null,
      );
      expect(route, RouteNames.onboardingStatus);
    });

    test('navigates to subscriptionStatus for active admin', () {
      const clinic = ClinicDetails(
        id: 'cln-1',
        name: 'Apex Dental',
        clinicType: 'General',
        address: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'contact@apex.com',
        status: ClinicStatus.active,
        isEmailVerified: true,
        onboardingStatus: InternalOnboardingStatus.complete,
      );

      final subscription = CurrentSubscription(
        id: 'sub-1',
        plan: const SubscriptionPlan(
          id: 'plan-pro',
          name: 'Pro',
          monthlyPrice: 3999,
          features: [],
          limits: {},
        ),
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 30)),
      );

      final route = RouteGuards.resolvePostLoginDestination(
        user: adminUser,
        clinic: clinic,
        subscription: subscription,
      );
      expect(route, RouteNames.subscriptionStatus);
    });

    test('navigates to clinicSettings for active non-admin staff', () {
      const clinic = ClinicDetails(
        id: 'cln-1',
        name: 'Apex Dental',
        clinicType: 'General',
        address: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        primaryContactName: 'Dr. Elena',
        primaryPhone: '+91 98765 43210',
        primaryEmail: 'contact@apex.com',
        status: ClinicStatus.active,
        isEmailVerified: true,
        onboardingStatus: InternalOnboardingStatus.complete,
      );

      final subscription = CurrentSubscription(
        id: 'sub-1',
        plan: const SubscriptionPlan(
          id: 'plan-pro',
          name: 'Pro',
          monthlyPrice: 3999,
          features: [],
          limits: {},
        ),
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 30)),
      );

      final route = RouteGuards.resolvePostLoginDestination(
        user: staffUser,
        clinic: clinic,
        subscription: subscription,
      );
      expect(route, RouteNames.clinicSettings);
    });
  });
}
