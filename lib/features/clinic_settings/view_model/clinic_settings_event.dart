import 'package:equatable/equatable.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/user_model.dart';

abstract class ClinicSettingsEvent extends Equatable {
  const ClinicSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadClinicSettingsRequested extends ClinicSettingsEvent {}

class UpdateClinicProfileRequested extends ClinicSettingsEvent {
  final UserModel currentUser;
  final ClinicDetails updatedClinic;

  const UpdateClinicProfileRequested({
    required this.currentUser,
    required this.updatedClinic,
  });

  @override
  List<Object?> get props => [currentUser, updatedClinic];
}

class UpdateOperationalSettingsRequested extends ClinicSettingsEvent {
  final UserModel currentUser;
  final OperationalSettings updatedSettings;

  const UpdateOperationalSettingsRequested({
    required this.currentUser,
    required this.updatedSettings,
  });

  @override
  List<Object?> get props => [currentUser, updatedSettings];
}
