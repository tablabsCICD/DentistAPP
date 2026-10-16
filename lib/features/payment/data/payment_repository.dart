import '../../../core/errors/app_exception.dart';
import '../../../shared/models/subscription_model.dart';

enum PaymentOutcome {
  success,
  failure,
  cancelled,
}

class CheckoutSession {
  final String transactionId;
  final SubscriptionPlan plan;
  final double amount;
  final String currency;

  const CheckoutSession({
    required this.transactionId,
    required this.plan,
    required this.amount,
    required this.currency,
  });
}

abstract class PaymentRepository {
  Future<CheckoutSession> startCheckout({required SubscriptionPlan plan});
  Future<PaymentOutcome> processPayment({
    required String transactionId,
    required PaymentOutcome outcome,
  });
}

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<CheckoutSession> startCheckout({required SubscriptionPlan plan}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CheckoutSession(
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      plan: plan,
      amount: plan.monthlyPrice,
      currency: plan.currency,
    );
  }

  @override
  Future<PaymentOutcome> processPayment({
    required String transactionId,
    required PaymentOutcome outcome,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    switch (outcome) {
      case PaymentOutcome.success:
        return PaymentOutcome.success;
      case PaymentOutcome.failure:
        throw const PaymentException(
          'Your card was declined by the bank due to insufficient clinical credit line. Please use an alternate card.',
          code: 'CARD_DECLINED',
        );
      case PaymentOutcome.cancelled:
        return PaymentOutcome.cancelled;
    }
  }
}
