import '../../../core/errors/app_exception.dart';
import '../../../shared/models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<CurrentSubscription?> getCurrentSubscription();
  Future<CurrentSubscription> refreshSubscriptionStatus();
  Future<CurrentSubscription> cancelSubscription({required String subscriptionId});
  Future<CurrentSubscription> changePlan({
    required String subscriptionId,
    required SubscriptionPlan newPlan,
  });
}

class MockSubscriptionRepository implements SubscriptionRepository {
  static const List<SubscriptionPlan> _mockPlans = [
    SubscriptionPlan(
      id: 'plan-starter',
      name: 'Solo Practice',
      monthlyPrice: 1999,
      currency: '₹',
      billingPeriod: 'month',
      features: [
        '1 Dentist License',
        '3 Staff Logins',
        '250 AI Diagnostic Scans/mo',
        'Standard Dental Charting',
        'Email Support',
      ],
      limits: {
        'Dentists': '1',
        'Staff Seats': '3',
        'Monthly AI Scans': '250',
      },
      isPopular: false,
    ),
    SubscriptionPlan(
      id: 'plan-pro',
      name: 'Professional Clinic',
      monthlyPrice: 3999,
      currency: '₹',
      billingPeriod: 'month',
      features: [
        'Up to 5 Dentists',
        '15 Staff Logins',
        'Unlimited AI Scans & Panoramic Analysis',
        'Advanced Periodontal Charting',
        'Automated Patient Reminders',
        'Priority 24/7 Support',
      ],
      limits: {
        'Dentists': '5',
        'Staff Seats': '15',
        'Monthly AI Scans': 'Unlimited',
      },
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'plan-enterprise',
      name: 'Dental Hospital & Network',
      monthlyPrice: 8999,
      currency: '₹',
      billingPeriod: 'month',
      features: [
        'Unlimited Dentists & Specialists',
        'Unlimited Staff Members',
        'Multi-Branch Synchronization',
        'Custom PACS / DICOM Imaging Bridge',
        'Dedicated Clinical Account Manager',
        'Custom SLA Guarantee',
      ],
      limits: {
        'Dentists': 'Unlimited',
        'Staff Seats': 'Unlimited',
        'Branches': 'Unlimited',
      },
      isPopular: false,
    ),
  ];

  CurrentSubscription? _currentSubscription;

  void setCurrentSubscription(CurrentSubscription? subscription) {
    _currentSubscription = subscription;
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPlans;
  }

  @override
  Future<CurrentSubscription?> getCurrentSubscription() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _currentSubscription;
  }

  @override
  Future<CurrentSubscription> refreshSubscriptionStatus() async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Authoritative backend synchronization
    if (_currentSubscription == null) {
      _currentSubscription = CurrentSubscription(
        id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
        plan: _mockPlans[1], // Professional Clinic
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        renewalDate: DateTime.now().add(const Duration(days: 30)),
        paymentMethodSummary: 'Visa ending in 4242',
      );
    } else {
      _currentSubscription = _currentSubscription!.copyWith(
        status: SubscriptionStatus.active,
        lastPaymentError: null,
      );
    }

    return _currentSubscription!;
  }

  @override
  Future<CurrentSubscription> cancelSubscription({required String subscriptionId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentSubscription == null) {
      throw const ValidationException('No active subscription found to cancel.');
    }
    _currentSubscription = _currentSubscription!.copyWith(
      status: SubscriptionStatus.cancelled,
    );
    return _currentSubscription!;
  }

  @override
  Future<CurrentSubscription> changePlan({
    required String subscriptionId,
    required SubscriptionPlan newPlan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_currentSubscription == null) {
      throw const ValidationException('No active subscription found.');
    }
    _currentSubscription = _currentSubscription!.copyWith(
      plan: newPlan,
      status: SubscriptionStatus.active,
      renewalDate: DateTime.now().add(const Duration(days: 30)),
    );
    return _currentSubscription!;
  }
}
