import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionBloc({required SubscriptionRepository repository})
      : _repository = repository,
        super(const SubscriptionState()) {
    on<LoadSubscriptionPlansRequested>(_onLoadSubscriptionPlansRequested);
    on<SelectSubscriptionPlan>(_onSelectSubscriptionPlan);
    on<LoadCurrentSubscriptionRequested>(_onLoadCurrentSubscriptionRequested);
    on<CancelSubscriptionRequested>(_onCancelSubscriptionRequested);
    on<UpgradeSubscriptionPlanRequested>(_onUpgradeSubscriptionPlanRequested);
  }

  Future<void> _onLoadSubscriptionPlansRequested(
    LoadSubscriptionPlansRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final plans = await _repository.getAvailablePlans();
      final currentSub = await _repository.getCurrentSubscription();

      emit(state.copyWith(
        status: Status.success,
        availablePlans: plans,
        selectedPlan: state.selectedPlan ?? (plans.length > 1 ? plans[1] : (plans.isNotEmpty ? plans.first : null)),
        currentSubscription: currentSub,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to load subscription tiers.'));
    }
  }

  void _onSelectSubscriptionPlan(
    SelectSubscriptionPlan event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(state.copyWith(selectedPlan: event.plan));
  }

  Future<void> _onLoadCurrentSubscriptionRequested(
    LoadCurrentSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final sub = await _repository.getCurrentSubscription();
      emit(state.copyWith(
        status: Status.success,
        currentSubscription: sub,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }

  Future<void> _onCancelSubscriptionRequested(
    CancelSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final updated = await _repository.cancelSubscription(subscriptionId: event.subscriptionId);
      emit(state.copyWith(
        status: Status.success,
        currentSubscription: updated,
        successMessage: 'Subscription cancelled. You retain access until the end of your billing cycle.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }

  Future<void> _onUpgradeSubscriptionPlanRequested(
    UpgradeSubscriptionPlanRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final updated = await _repository.changePlan(
        subscriptionId: event.subscriptionId,
        newPlan: event.newPlan,
      );
      emit(state.copyWith(
        status: Status.success,
        currentSubscription: updated,
        successMessage: 'Successfully upgraded to ${event.newPlan.name}!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    }
  }
}
