import 'package:equatable/equatable.dart';
import '../domain/onboarding_form_data.dart';

abstract class ClinicOnboardingEvent extends Equatable {
  const ClinicOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class StepChanged extends ClinicOnboardingEvent {
  final int step;

  const StepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class FormDataUpdated extends ClinicOnboardingEvent {
  final OnboardingFormData data;

  const FormDataUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

class SubmitOnboardingRequested extends ClinicOnboardingEvent {}

class ResetOnboardingFlow extends ClinicOnboardingEvent {}
