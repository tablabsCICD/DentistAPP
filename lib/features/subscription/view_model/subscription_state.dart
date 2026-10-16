import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/subscription_model.dart';

class SubscriptionState extends Equatable {
  final Status status;
  final List<SubscriptionPlan> availablePlans;
  final SubscriptionPlan? selectedPlan;
  final CurrentSubscription? currentSubscription;
  final String? errorMessage;
  final String? successMessage;

  const SubscriptionState({
    this.status = Status.idle,
    this.availablePlans = const [],
    this.selectedPlan,
    this.currentSubscription,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == Status.loading;

  SubscriptionState copyWith({
    Status? status,
    List<SubscriptionPlan>? availablePlans,
    SubscriptionPlan? selectedPlan,
    CurrentSubscription? currentSubscription,
    String? errorMessage,
    String? successMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      availablePlans: availablePlans ?? this.availablePlans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availablePlans,
        selectedPlan,
        currentSubscription,
        errorMessage,
        successMessage,
      ];
}
