import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../../subscription/data/subscription_repository.dart';
import '../data/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;
  final SubscriptionRepository _subscriptionRepository;

  PaymentBloc({
    required PaymentRepository paymentRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _paymentRepository = paymentRepository,
        _subscriptionRepository = subscriptionRepository,
        super(const PaymentState()) {
    on<InitializeCheckoutSession>(_onInitializeCheckoutSession);
    on<ProcessPaymentTransaction>(_onProcessPaymentTransaction);
    on<RetryPaymentRequested>(_onRetryPaymentRequested);
  }

  Future<void> _onInitializeCheckoutSession(
    InitializeCheckoutSession event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, step: PaymentStep.initiating, errorMessage: null));

    try {
      final session = await _paymentRepository.startCheckout(plan: event.plan);
      emit(state.copyWith(
        status: Status.idle,
        step: PaymentStep.readyToPay,
        session: session,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        step: PaymentStep.failed,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> _onProcessPaymentTransaction(
    ProcessPaymentTransaction event,
    Emitter<PaymentState> emit,
  ) async {
    if (state.session == null) return;

    emit(state.copyWith(
      status: Status.loading,
      step: PaymentStep.processing,
      errorMessage: null,
    ));

    try {
      final outcome = await _paymentRepository.processPayment(
        transactionId: state.session!.transactionId,
        outcome: event.outcome,
      );

      if (outcome == PaymentOutcome.cancelled) {
        emit(state.copyWith(
          status: Status.idle,
          step: PaymentStep.cancelled,
          errorMessage: 'Payment was cancelled. You can retry whenever you are ready.',
        ));
        return;
      }

      // CRITICAL RULE: Never trust client-side payment success directly.
      // Refresh backend subscription status to verify authoritative state.
      emit(state.copyWith(step: PaymentStep.verifyingBackend));

      final confirmedSub = await _subscriptionRepository.refreshSubscriptionStatus();

      emit(state.copyWith(
        status: Status.success,
        step: PaymentStep.success,
        confirmedSubscription: confirmedSub,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        step: PaymentStep.failed,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        step: PaymentStep.failed,
        errorMessage: 'Payment processing encountered an unexpected error. Please retry.',
      ));
    }
  }

  void _onRetryPaymentRequested(
    RetryPaymentRequested event,
    Emitter<PaymentState> emit,
  ) {
    emit(state.copyWith(
      status: Status.idle,
      step: PaymentStep.readyToPay,
      errorMessage: null,
    ));
  }
}
