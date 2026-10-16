import 'package:equatable/equatable.dart';

abstract class OnboardingStatusEvent extends Equatable {
  const OnboardingStatusEvent();

  @override
  List<Object?> get props => [];
}

class FetchOnboardingStatusRequested extends OnboardingStatusEvent {}
