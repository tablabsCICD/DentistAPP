import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/subscription_model.dart';

class OnboardingStatusState extends Equatable {
  final Status status;
  final ClinicDetails? clinic;
  final CurrentSubscription? subscription;
  final String? errorMessage;

  const OnboardingStatusState({
    this.status = Status.idle,
    this.clinic,
    this.subscription,
    this.errorMessage,
  });

  bool get isLoading => status == Status.loading;

  OnboardingStatusState copyWith({
    Status? status,
    ClinicDetails? clinic,
    CurrentSubscription? subscription,
    String? errorMessage,
  }) {
    return OnboardingStatusState(
      status: status ?? this.status,
      clinic: clinic ?? this.clinic,
      subscription: subscription ?? this.subscription,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clinic, subscription, errorMessage];
}
