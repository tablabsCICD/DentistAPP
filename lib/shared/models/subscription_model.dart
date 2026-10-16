import 'package:equatable/equatable.dart';

enum SubscriptionStatus {
  active,
  pending,
  paymentPending,
  paymentFailed,
  gracePeriod,
  cancelled,
  expired,
  blocked,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return 'Pending Activation';
      case SubscriptionStatus.paymentPending:
        return 'Payment Pending';
      case SubscriptionStatus.paymentFailed:
        return 'Payment Failed';
      case SubscriptionStatus.gracePeriod:
        return 'Grace Period';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.blocked:
        return 'Blocked';
    }
  }

  String get code {
    switch (this) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.pending:
        return 'PENDING';
      case SubscriptionStatus.paymentPending:
        return 'PAYMENT_PENDING';
      case SubscriptionStatus.paymentFailed:
        return 'PAYMENT_FAILED';
      case SubscriptionStatus.gracePeriod:
        return 'GRACE_PERIOD';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.blocked:
        return 'BLOCKED';
    }
  }
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final double monthlyPrice;
  final String currency;
  final String billingPeriod;
  final List<String> features;
  final Map<String, dynamic> limits;
  final bool isPopular;
  final bool isAvailable;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    this.currency = '₹',
    this.billingPeriod = 'month',
    required this.features,
    required this.limits,
    this.isPopular = false,
    this.isAvailable = true,
  });

  String get formattedPrice => '$currency${monthlyPrice.toStringAsFixed(0)} / $billingPeriod';

  @override
  List<Object?> get props => [
        id,
        name,
        monthlyPrice,
        currency,
        billingPeriod,
        features,
        limits,
        isPopular,
        isAvailable,
      ];
}

class CurrentSubscription extends Equatable {
  final String id;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime renewalDate;
  final DateTime? gracePeriodEndsAt;
  final String? lastPaymentError;
  final String? paymentMethodSummary;

  const CurrentSubscription({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.renewalDate,
    this.gracePeriodEndsAt,
    this.lastPaymentError,
    this.paymentMethodSummary,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isInGracePeriod => status == SubscriptionStatus.gracePeriod;
  bool get hasPaymentFailed => status == SubscriptionStatus.paymentFailed;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  CurrentSubscription copyWith({
    String? id,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? renewalDate,
    DateTime? gracePeriodEndsAt,
    String? lastPaymentError,
    String? paymentMethodSummary,
  }) {
    return CurrentSubscription(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      renewalDate: renewalDate ?? this.renewalDate,
      gracePeriodEndsAt: gracePeriodEndsAt ?? this.gracePeriodEndsAt,
      lastPaymentError: lastPaymentError ?? this.lastPaymentError,
      paymentMethodSummary: paymentMethodSummary ?? this.paymentMethodSummary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        plan,
        status,
        startDate,
        renewalDate,
        gracePeriodEndsAt,
        lastPaymentError,
        paymentMethodSummary,
      ];
}
