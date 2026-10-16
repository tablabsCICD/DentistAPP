import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/patient_model.dart';

class PatientState extends Equatable {
  final Status status;
  final List<PatientModel> patients;
  final List<PatientModel> filteredPatients;
  final PatientModel? selectedPatient;
  final String searchQuery;
  final PatientStatus? statusFilter;
  final PatientRiskLevel? riskFilter;
  final String sortBy;
  final bool isFormSuccess;
  final bool isActionSuccess;
  final String? successMessage;
  final String? errorMessage;
  final Map<String, dynamic>? statistics;

  const PatientState({
    this.status = Status.idle,
    this.patients = const [],
    this.filteredPatients = const [],
    this.selectedPatient,
    this.searchQuery = '',
    this.statusFilter,
    this.riskFilter,
    this.sortBy = 'recent',
    this.isFormSuccess = false,
    this.isActionSuccess = false,
    this.successMessage,
    this.errorMessage,
    this.statistics,
  });

  PatientState copyWith({
    Status? status,
    List<PatientModel>? patients,
    List<PatientModel>? filteredPatients,
    PatientModel? selectedPatient,
    bool clearSelectedPatient = false,
    String? searchQuery,
    PatientStatus? statusFilter,
    bool clearStatusFilter = false,
    PatientRiskLevel? riskFilter,
    bool clearRiskFilter = false,
    String? sortBy,
    bool? isFormSuccess,
    bool? isActionSuccess,
    String? successMessage,
    String? errorMessage,
    Map<String, dynamic>? statistics,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      filteredPatients: filteredPatients ?? this.filteredPatients,
      selectedPatient: clearSelectedPatient ? null : (selectedPatient ?? this.selectedPatient),
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      riskFilter: clearRiskFilter ? null : (riskFilter ?? this.riskFilter),
      sortBy: sortBy ?? this.sortBy,
      isFormSuccess: isFormSuccess ?? false,
      isActionSuccess: isActionSuccess ?? false,
      successMessage: successMessage,
      errorMessage: errorMessage,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        filteredPatients,
        selectedPatient,
        searchQuery,
        statusFilter,
        riskFilter,
        sortBy,
        isFormSuccess,
        isActionSuccess,
        successMessage,
        errorMessage,
        statistics,
      ];
}
