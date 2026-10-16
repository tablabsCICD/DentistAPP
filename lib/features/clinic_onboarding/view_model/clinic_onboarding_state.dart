import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/clinic_model.dart';
import '../domain/onboarding_form_data.dart';

class ClinicOnboardingState extends Equatable {
  final Status status;
  final int currentStep;
  final OnboardingFormData formData;
  final ClinicDetails? createdClinic;
  final String? errorMessage;

  const ClinicOnboardingState({
    this.status = Status.idle,
    this.currentStep = 0,
    this.formData = const OnboardingFormData(),
    this.createdClinic,
    this.errorMessage,
  });

  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;

  ClinicOnboardingState copyWith({
    Status? status,
    int? currentStep,
    OnboardingFormData? formData,
    ClinicDetails? createdClinic,
    String? errorMessage,
  }) {
    return ClinicOnboardingState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      createdClinic: createdClinic ?? this.createdClinic,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        formData,
        createdClinic,
        errorMessage,
      ];
}
