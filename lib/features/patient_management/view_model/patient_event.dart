import 'package:equatable/equatable.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientsRequested extends PatientEvent {
  const LoadPatientsRequested();
}

class SearchQueryChanged extends PatientEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class StatusFilterChanged extends PatientEvent {
  final PatientStatus? status;

  const StatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class RiskFilterChanged extends PatientEvent {
  final PatientRiskLevel? risk;

  const RiskFilterChanged(this.risk);

  @override
  List<Object?> get props => [risk];
}

class SortOrderChanged extends PatientEvent {
  final String sortBy; // 'recent', 'name', 'risk', 'age'

  const SortOrderChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SelectPatientRequested extends PatientEvent {
  final String patientId;

  const SelectPatientRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class RegisterPatientSubmitted extends PatientEvent {
  final PatientModel patient;
  final UserModel currentUser;

  const RegisterPatientSubmitted({
    required this.patient,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patient, currentUser];
}

class UpdatePatientSubmitted extends PatientEvent {
  final PatientModel patient;
  final UserModel currentUser;

  const UpdatePatientSubmitted({
    required this.patient,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patient, currentUser];
}

class ArchivePatientRequested extends PatientEvent {
  final String patientId;
  final UserModel currentUser;

  const ArchivePatientRequested({
    required this.patientId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, currentUser];
}

class AddClinicalNoteSubmitted extends PatientEvent {
  final String patientId;
  final String title;
  final String content;
  final UserModel currentUser;

  const AddClinicalNoteSubmitted({
    required this.patientId,
    required this.title,
    required this.content,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, title, content, currentUser];
}

class ScheduleAppointmentSubmitted extends PatientEvent {
  final String patientId;
  final DateTime date;
  final String timeSlot;
  final String procedure;
  final String dentistName;
  final UserModel currentUser;

  const ScheduleAppointmentSubmitted({
    required this.patientId,
    required this.date,
    required this.timeSlot,
    required this.procedure,
    required this.dentistName,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [
        patientId,
        date,
        timeSlot,
        procedure,
        dentistName,
        currentUser,
      ];
}
