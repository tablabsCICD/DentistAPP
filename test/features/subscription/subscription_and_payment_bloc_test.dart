import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/payment/data/payment_repository.dart';
import 'package:ai_dental_app/features/payment/view_model/payment_bloc.dart';
import 'package:ai_dental_app/features/payment/view_model/payment_event.dart';
import 'package:ai_dental_app/features/payment/view_model/payment_state.dart';
import 'package:ai_dental_app/features/subscription/data/subscription_repository.dart';
import 'package:ai_dental_app/features/subscription/view_model/subscription_bloc.dart';
import 'package:ai_dental_app/features/subscription/view_model/subscription_event.dart';
import 'package:ai_dental_app/features/subscription/view_model/subscription_state.dart';
import 'package:ai_dental_app/shared/models/subscription_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionBloc and PaymentBloc Tests', () {
    late MockSubscriptionRepository mockSubRepo;
    late MockPaymentRepository mockPaymentRepo;

    const testPlan = SubscriptionPlan(
      id: 'plan-pro',
      name: 'Professional Clinic',
      monthlyPrice: 3999,
      features: ['Unlimited AI Diagnostics'],
      limits: {'Dentists': '5'},
    );

    setUp(() {
      mockSubRepo = MockSubscriptionRepository();
      mockPaymentRepo = MockPaymentRepository();
    });

    blocTest<SubscriptionBloc, SubscriptionState>(
      'loads subscription plans successfully',
      build: () => SubscriptionBloc(repository: mockSubRepo),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(LoadSubscriptionPlansRequested()),
      expect: () => [
        const SubscriptionState(status: Status.loading),
        predicate<SubscriptionState>((state) {
          return state.status == Status.success &&
              state.availablePlans.isNotEmpty &&
              state.selectedPlan != null;
        }),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'starts checkout session and reaches readyToPay step',
      build: () => PaymentBloc(
        paymentRepository: mockPaymentRepo,
        subscriptionRepository: mockSubRepo,
      ),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) => bloc.add(const InitializeCheckoutSession(testPlan)),
      expect: () => [
        const PaymentState(status: Status.loading, step: PaymentStep.initiating),
        predicate<PaymentState>((state) {
          return state.step == PaymentStep.readyToPay &&
              state.session != null &&
              state.session!.plan.id == 'plan-pro';
        }),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'executes payment success, refreshes backend subscription status, and confirms active state',
      build: () => PaymentBloc(
        paymentRepository: mockPaymentRepo,
        subscriptionRepository: mockSubRepo,
      ),
      wait: const Duration(milliseconds: 2200),
      seed: () => const PaymentState(
        step: PaymentStep.readyToPay,
        session: CheckoutSession(
          transactionId: 'txn-123',
          plan: testPlan,
          amount: 3999,
          currency: '₹',
        ),
      ),
      act: (bloc) => bloc.add(const ProcessPaymentTransaction(PaymentOutcome.success)),
      expect: () => [
        predicate<PaymentState>((s) => s.step == PaymentStep.processing),
        predicate<PaymentState>((s) => s.step == PaymentStep.verifyingBackend),
        predicate<PaymentState>((s) {
          return s.step == PaymentStep.success &&
              s.status == Status.success &&
              s.confirmedSubscription != null &&
              s.confirmedSubscription!.isActive;
        }),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'handles card decline / payment failure with retry support',
      build: () => PaymentBloc(
        paymentRepository: mockPaymentRepo,
        subscriptionRepository: mockSubRepo,
      ),
      wait: const Duration(milliseconds: 1200),
      seed: () => const PaymentState(
        step: PaymentStep.readyToPay,
        session: CheckoutSession(
          transactionId: 'txn-123',
          plan: testPlan,
          amount: 3999,
          currency: '₹',
        ),
      ),
      act: (bloc) => bloc.add(const ProcessPaymentTransaction(PaymentOutcome.failure)),
      expect: () => [
        predicate<PaymentState>((s) => s.step == PaymentStep.processing),
        predicate<PaymentState>((s) {
          return s.step == PaymentStep.failed &&
              s.status == Status.error &&
              s.errorMessage != null &&
              s.errorMessage!.contains('declined');
        }),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'handles user cancellation gracefully',
      build: () => PaymentBloc(
        paymentRepository: mockPaymentRepo,
        subscriptionRepository: mockSubRepo,
      ),
      wait: const Duration(milliseconds: 1200),
      seed: () => const PaymentState(
        step: PaymentStep.readyToPay,
        session: CheckoutSession(
          transactionId: 'txn-123',
          plan: testPlan,
          amount: 3999,
          currency: '₹',
        ),
      ),
      act: (bloc) => bloc.add(const ProcessPaymentTransaction(PaymentOutcome.cancelled)),
      expect: () => [
        predicate<PaymentState>((s) => s.step == PaymentStep.processing),
        predicate<PaymentState>((s) {
          return s.step == PaymentStep.cancelled &&
              s.errorMessage != null &&
              s.errorMessage!.contains('cancelled');
        }),
      ],
    );
  });
}
