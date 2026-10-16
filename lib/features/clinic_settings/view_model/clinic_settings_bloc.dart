import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/clinic_settings_repository.dart';
import 'clinic_settings_event.dart';
import 'clinic_settings_state.dart';

class ClinicSettingsBloc extends Bloc<ClinicSettingsEvent, ClinicSettingsState> {
  final ClinicSettingsRepository _repository;

  ClinicSettingsBloc({required ClinicSettingsRepository repository})
      : _repository = repository,
        super(const ClinicSettingsState()) {
    on<LoadClinicSettingsRequested>(_onLoadClinicSettingsRequested);
    on<UpdateClinicProfileRequested>(_onUpdateClinicProfileRequested);
    on<UpdateOperationalSettingsRequested>(_onUpdateOperationalSettingsRequested);
  }

  Future<void> _onLoadClinicSettingsRequested(
    LoadClinicSettingsRequested event,
    Emitter<ClinicSettingsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, successMessage: null));

    try {
      final clinic = await _repository.getClinicSettings();
      emit(state.copyWith(
        status: Status.success,
        clinic: clinic,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to load clinic settings.'));
    }
  }

  Future<void> _onUpdateClinicProfileRequested(
    UpdateClinicProfileRequested event,
    Emitter<ClinicSettingsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, successMessage: null));

    try {
      final updated = await _repository.updateClinicProfile(
        currentUser: event.currentUser,
        updatedClinic: event.updatedClinic,
      );
      emit(state.copyWith(
        status: Status.success,
        clinic: updated,
        successMessage: 'Clinic profile successfully updated!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to save profile changes.'));
    }
  }

  Future<void> _onUpdateOperationalSettingsRequested(
    UpdateOperationalSettingsRequested event,
    Emitter<ClinicSettingsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, successMessage: null));

    try {
      final updatedOps = await _repository.updateOperationalSettings(
        currentUser: event.currentUser,
        updatedSettings: event.updatedSettings,
      );
      if (state.clinic != null) {
        emit(state.copyWith(
          status: Status.success,
          clinic: state.clinic!.copyWith(operationalSettings: updatedOps),
          successMessage: 'Operational settings saved successfully!',
        ));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to update operational parameters.'));
    }
  }
}
