import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/subscription_model.dart';
import '../data/payment_repository.dart';

enum PaymentStep {
  initiating,
  readyToPay,
  processing,
  verifyingBackend,
  success,
  failed,
  cancelled,
}

class PaymentState extends Equatable {
  final Status status;
  final PaymentStep step;
  final CheckoutSession? session;
  final CurrentSubscription? confirmedSubscription;
  final String? errorMessage;

  const PaymentState({
    this.status = Status.idle,
    this.step = PaymentStep.initiating,
    this.session,
    this.confirmedSubscription,
    this.errorMessage,
  });

  bool get isProcessing =>
      step == PaymentStep.processing || step == PaymentStep.verifyingBackend || status == Status.loading;

  PaymentState copyWith({
    Status? status,
    PaymentStep? step,
    CheckoutSession? session,
    CurrentSubscription? confirmedSubscription,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      step: step ?? this.step,
      session: session ?? this.session,
      confirmedSubscription: confirmedSubscription ?? this.confirmedSubscription,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        step,
        session,
        confirmedSubscription,
        errorMessage,
      ];
}
