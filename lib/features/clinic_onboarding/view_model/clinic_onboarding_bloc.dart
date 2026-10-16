import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/clinic_onboarding_repository.dart';
import 'clinic_onboarding_event.dart';
import 'clinic_onboarding_state.dart';

class ClinicOnboardingBloc extends Bloc<ClinicOnboardingEvent, ClinicOnboardingState> {
  final ClinicOnboardingRepository _repository;

  ClinicOnboardingBloc({required ClinicOnboardingRepository repository})
      : _repository = repository,
        super(const ClinicOnboardingState()) {
    on<StepChanged>(_onStepChanged);
    on<FormDataUpdated>(_onFormDataUpdated);
    on<SubmitOnboardingRequested>(_onSubmitOnboardingRequested);
    on<ResetOnboardingFlow>(_onResetOnboardingFlow);
  }

  void _onStepChanged(StepChanged event, Emitter<ClinicOnboardingState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onFormDataUpdated(FormDataUpdated event, Emitter<ClinicOnboardingState> emit) {
    emit(state.copyWith(formData: event.data));
  }

  Future<void> _onSubmitOnboardingRequested(
    SubmitOnboardingRequested event,
    Emitter<ClinicOnboardingState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final clinic = await _repository.submitClinicOnboarding(state.formData);
      emit(state.copyWith(
        status: Status.success,
        createdClinic: clinic,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Registration failed. Please review your clinic details and try again.',
      ));
    }
  }

  void _onResetOnboardingFlow(ResetOnboardingFlow event, Emitter<ClinicOnboardingState> emit) {
    emit(const ClinicOnboardingState());
  }
}
