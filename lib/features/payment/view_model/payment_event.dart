import 'package:equatable/equatable.dart';
import '../../../shared/models/subscription_model.dart';
import '../data/payment_repository.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCheckoutSession extends PaymentEvent {
  final SubscriptionPlan plan;

  const InitializeCheckoutSession(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ProcessPaymentTransaction extends PaymentEvent {
  final PaymentOutcome outcome;

  const ProcessPaymentTransaction(this.outcome);

  @override
  List<Object?> get props => [outcome];
}

class RetryPaymentRequested extends PaymentEvent {}
