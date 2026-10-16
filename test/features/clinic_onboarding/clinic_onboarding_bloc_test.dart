import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/clinic_onboarding/data/clinic_onboarding_repository.dart';
import 'package:ai_dental_app/features/clinic_onboarding/domain/onboarding_form_data.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_bloc.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_event.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicOnboardingBloc Tests', () {
    late MockClinicOnboardingRepository mockRepo;

    setUp(() {
      mockRepo = MockClinicOnboardingRepository();
    });

    test('preserves form data when step changes', () {
      final bloc = ClinicOnboardingBloc(repository: mockRepo);
      const testData = OnboardingFormData(clinicName: 'Tooth Fairy Clinic');

      bloc.add(const FormDataUpdated(testData));
      bloc.add(const StepChanged(1));

      expectLater(
        bloc.stream,
        emitsInOrder([
          const ClinicOnboardingState(currentStep: 0, formData: testData),
          const ClinicOnboardingState(currentStep: 1, formData: testData),
        ]),
      );
    });

    blocTest<ClinicOnboardingBloc, ClinicOnboardingState>(
      'submits clinic onboarding and receives created ClinicDetails',
      build: () => ClinicOnboardingBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      seed: () => const ClinicOnboardingState(
        currentStep: 2,
        formData: OnboardingFormData(
          clinicName: 'Apex Dental',
          primaryContactName: 'Dr. Elena',
          primaryPhone: '+91 98765 43210',
          primaryEmail: 'contact@apexdental.com',
        ),
      ),
      act: (bloc) => bloc.add(SubmitOnboardingRequested()),
      expect: () => [
        predicate<ClinicOnboardingState>((state) => state.status == Status.loading),
        predicate<ClinicOnboardingState>((state) {
          return state.status == Status.success &&
              state.createdClinic != null &&
              state.createdClinic!.name == 'Apex Dental';
        }),
      ],
    );
  });
}
