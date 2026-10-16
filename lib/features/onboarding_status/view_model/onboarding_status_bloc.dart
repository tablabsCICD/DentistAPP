import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/onboarding_status_repository.dart';
import 'onboarding_status_event.dart';
import 'onboarding_status_state.dart';

class OnboardingStatusBloc extends Bloc<OnboardingStatusEvent, OnboardingStatusState> {
  final OnboardingStatusRepository _repository;

  OnboardingStatusBloc({required OnboardingStatusRepository repository})
      : _repository = repository,
        super(const OnboardingStatusState()) {
    on<FetchOnboardingStatusRequested>(_onFetchOnboardingStatusRequested);
  }

  Future<void> _onFetchOnboardingStatusRequested(
    FetchOnboardingStatusRequested event,
    Emitter<OnboardingStatusState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final data = await _repository.getOnboardingStatus();
      emit(state.copyWith(
        status: Status.success,
        clinic: data.clinic,
        subscription: data.subscription,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unable to load clinic onboarding status. Please refresh.',
      ));
    }
  }
}
