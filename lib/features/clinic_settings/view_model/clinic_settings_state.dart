import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';
import '../../../shared/models/clinic_model.dart';

class ClinicSettingsState extends Equatable {
  final Status status;
  final ClinicDetails? clinic;
  final String? errorMessage;
  final String? successMessage;

  const ClinicSettingsState({
    this.status = Status.idle,
    this.clinic,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == Status.loading;

  ClinicSettingsState copyWith({
    Status? status,
    ClinicDetails? clinic,
    String? errorMessage,
    String? successMessage,
  }) {
    return ClinicSettingsState(
      status: status ?? this.status,
      clinic: clinic ?? this.clinic,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        clinic,
        errorMessage,
        successMessage,
      ];
}
