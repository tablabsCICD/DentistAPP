import 'package:equatable/equatable.dart';
import '../../../shared/models/subscription_model.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionPlansRequested extends SubscriptionEvent {}

class SelectSubscriptionPlan extends SubscriptionEvent {
  final SubscriptionPlan plan;

  const SelectSubscriptionPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class LoadCurrentSubscriptionRequested extends SubscriptionEvent {}

class CancelSubscriptionRequested extends SubscriptionEvent {
  final String subscriptionId;

  const CancelSubscriptionRequested(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class UpgradeSubscriptionPlanRequested extends SubscriptionEvent {
  final String subscriptionId;
  final SubscriptionPlan newPlan;

  const UpgradeSubscriptionPlanRequested({
    required this.subscriptionId,
    required this.newPlan,
  });

  @override
  List<Object?> get props => [subscriptionId, newPlan];
}
