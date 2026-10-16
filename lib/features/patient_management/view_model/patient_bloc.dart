import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/patient_model.dart';
import '../data/patient_repository.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _repository;

  PatientBloc({required PatientRepository repository})
      : _repository = repository,
        super(const PatientState()) {
    on<LoadPatientsRequested>(_onLoadPatientsRequested);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<RiskFilterChanged>(_onRiskFilterChanged);
    on<SortOrderChanged>(_onSortOrderChanged);
    on<SelectPatientRequested>(_onSelectPatientRequested);
    on<RegisterPatientSubmitted>(_onRegisterPatientSubmitted);
    on<UpdatePatientSubmitted>(_onUpdatePatientSubmitted);
    on<ArchivePatientRequested>(_onArchivePatientRequested);
    on<AddClinicalNoteSubmitted>(_onAddClinicalNoteSubmitted);
    on<ScheduleAppointmentSubmitted>(_onScheduleAppointmentSubmitted);
  }

  Future<void> _onLoadPatientsRequested(
    LoadPatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final patients = await _repository.getPatients();
      final stats = await _repository.getPatientStatistics();

      final filtered = _applyFiltersAndSort(
        patients,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: patients,
        filteredPatients: filtered,
        statistics: stats,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to load patient records.'));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<PatientState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.patients,
      query: event.query,
      status: state.statusFilter,
      risk: state.riskFilter,
      sortBy: state.sortBy,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredPatients: filtered,
    ));
  }

  void _onStatusFilterChanged(
    StatusFilterChanged event,
    Emitter<PatientState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.patients,
      query: state.searchQuery,
      status: event.status,
      risk: state.riskFilter,
      sortBy: state.sortBy,
    );

    emit(state.copyWith(
      statusFilter: event.status,
      clearStatusFilter: event.status == null,
      filteredPatients: filtered,
    ));
  }

  void _onRiskFilterChanged(
    RiskFilterChanged event,
    Emitter<PatientState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.patients,
      query: state.searchQuery,
      status: state.statusFilter,
      risk: event.risk,
      sortBy: state.sortBy,
    );

    emit(state.copyWith(
      riskFilter: event.risk,
      clearRiskFilter: event.risk == null,
      filteredPatients: filtered,
    ));
  }

  void _onSortOrderChanged(
    SortOrderChanged event,
    Emitter<PatientState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.patients,
      query: state.searchQuery,
      status: state.statusFilter,
      risk: state.riskFilter,
      sortBy: event.sortBy,
    );

    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredPatients: filtered,
    ));
  }

  Future<void> _onSelectPatientRequested(
    SelectPatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final patient = await _repository.getPatientById(event.patientId);
      emit(state.copyWith(
        status: Status.success,
        selectedPatient: patient,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to retrieve patient profile.'));
    }
  }

  Future<void> _onRegisterPatientSubmitted(
    RegisterPatientSubmitted event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, isFormSuccess: false));

    try {
      final newPatient = await _repository.registerPatient(
        patient: event.patient,
        currentUser: event.currentUser,
      );

      final updatedList = List<PatientModel>.from(state.patients)..insert(0, newPatient);
      final stats = await _repository.getPatientStatistics();

      final filtered = _applyFiltersAndSort(
        updatedList,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: updatedList,
        filteredPatients: filtered,
        selectedPatient: newPatient,
        statistics: stats,
        isFormSuccess: true,
        successMessage: 'Patient ${newPatient.fullName} (${newPatient.patientNumber}) registered successfully.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to register new patient.'));
    }
  }

  Future<void> _onUpdatePatientSubmitted(
    UpdatePatientSubmitted event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, isFormSuccess: false));

    try {
      final updatedPatient = await _repository.updatePatient(
        patient: event.patient,
        currentUser: event.currentUser,
      );

      final updatedList = state.patients.map((p) => p.id == updatedPatient.id ? updatedPatient : p).toList();
      final stats = await _repository.getPatientStatistics();

      final filtered = _applyFiltersAndSort(
        updatedList,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: updatedList,
        filteredPatients: filtered,
        selectedPatient: updatedPatient,
        statistics: stats,
        isFormSuccess: true,
        successMessage: 'Patient profile for ${updatedPatient.fullName} updated successfully.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to update patient information.'));
    }
  }

  Future<void> _onArchivePatientRequested(
    ArchivePatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.archivePatient(
        patientId: event.patientId,
        currentUser: event.currentUser,
      );

      final updatedList = state.patients.map((p) {
        if (p.id == event.patientId) {
          return p.copyWith(status: PatientStatus.archived);
        }
        return p;
      }).toList();

      final stats = await _repository.getPatientStatistics();

      final filtered = _applyFiltersAndSort(
        updatedList,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: updatedList,
        filteredPatients: filtered,
        statistics: stats,
        isActionSuccess: true,
        successMessage: 'Patient record archived.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to archive patient record.'));
    }
  }

  Future<void> _onAddClinicalNoteSubmitted(
    AddClinicalNoteSubmitted event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final note = await _repository.addClinicalNote(
        patientId: event.patientId,
        title: event.title,
        content: event.content,
        currentUser: event.currentUser,
      );

      // Update in memory selected patient & list
      final updatedList = state.patients.map((p) {
        if (p.id == event.patientId) {
          final updatedNotes = List<ClinicalNote>.from(p.clinicalNotes)..insert(0, note);
          return p.copyWith(clinicalNotes: updatedNotes);
        }
        return p;
      }).toList();

      PatientModel? updatedSelected = state.selectedPatient;
      if (updatedSelected != null && updatedSelected.id == event.patientId) {
        final updatedNotes = List<ClinicalNote>.from(updatedSelected.clinicalNotes)..insert(0, note);
        updatedSelected = updatedSelected.copyWith(clinicalNotes: updatedNotes);
      }

      final filtered = _applyFiltersAndSort(
        updatedList,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: updatedList,
        filteredPatients: filtered,
        selectedPatient: updatedSelected,
        isActionSuccess: true,
        successMessage: 'Clinical note added.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to add clinical note.'));
    }
  }

  Future<void> _onScheduleAppointmentSubmitted(
    ScheduleAppointmentSubmitted event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final appointment = await _repository.scheduleAppointment(
        patientId: event.patientId,
        date: event.date,
        timeSlot: event.timeSlot,
        procedure: event.procedure,
        dentistName: event.dentistName,
        currentUser: event.currentUser,
      );

      final updatedList = state.patients.map((p) {
        if (p.id == event.patientId) {
          final updatedAppointments = List<PatientAppointment>.from(p.appointments)..insert(0, appointment);
          return p.copyWith(
            appointments: updatedAppointments,
            nextAppointmentDate: event.date,
          );
        }
        return p;
      }).toList();

      PatientModel? updatedSelected = state.selectedPatient;
      if (updatedSelected != null && updatedSelected.id == event.patientId) {
        final updatedAppointments = List<PatientAppointment>.from(updatedSelected.appointments)..insert(0, appointment);
        updatedSelected = updatedSelected.copyWith(
          appointments: updatedAppointments,
          nextAppointmentDate: event.date,
        );
      }

      final filtered = _applyFiltersAndSort(
        updatedList,
        query: state.searchQuery,
        status: state.statusFilter,
        risk: state.riskFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: Status.success,
        patients: updatedList,
        filteredPatients: filtered,
        selectedPatient: updatedSelected,
        isActionSuccess: true,
        successMessage: 'Appointment scheduled for ${event.procedure}.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: 'Failed to schedule appointment.'));
    }
  }

  List<PatientModel> _applyFiltersAndSort(
    List<PatientModel> patients, {
    String? query,
    PatientStatus? status,
    PatientRiskLevel? risk,
    String? sortBy,
  }) {
    var results = List<PatientModel>.from(patients);

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((p) {
        return p.fullName.toLowerCase().contains(q) ||
            p.patientNumber.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q) ||
            p.phone.toLowerCase().contains(q) ||
            (p.assignedDentistName?.toLowerCase().contains(q) ?? false) ||
            (p.insuranceProvider?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (status != null) {
      results = results.where((p) => p.status == status).toList();
    }

    if (risk != null) {
      results = results.where((p) => p.riskLevel == risk).toList();
    }

    switch (sortBy?.toLowerCase()) {
      case 'name':
        results.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'risk':
        final riskOrder = {
          PatientRiskLevel.high: 3,
          PatientRiskLevel.medium: 2,
          PatientRiskLevel.low: 1,
        };
        results.sort((a, b) => (riskOrder[b.riskLevel] ?? 0).compareTo(riskOrder[a.riskLevel] ?? 0));
        break;
      case 'age':
        results.sort((a, b) => a.dateOfBirth.compareTo(b.dateOfBirth));
        break;
      case 'recent':
      default:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return results;
  }
}
