import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/patient_management/data/patient_repository.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_bloc.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_event.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_state.dart';
import 'package:ai_dental_app/shared/models/patient_model.dart';
import 'package:ai_dental_app/shared/models/user_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Patient Model Tests', () {
    test('calculates patient age correctly from dateOfBirth', () {
      final dob = DateTime(1990, 6, 15);
      final patient = PatientModel(
        id: 'pat-test',
        patientNumber: 'PT-2026-0001',
        firstName: 'Rahul',
        lastName: 'Sharma',
        email: 'rahul@test.com',
        phone: '+91 98765 00000',
        dateOfBirth: dob,
        gender: PatientGender.male,
        bloodGroup: 'O+',
        createdAt: DateTime.now(),
      );

      final now = DateTime.now();
      int expectedAge = now.year - 1990;
      if (now.month < 6 || (now.month == 6 && now.day < 15)) {
        expectedAge--;
      }

      expect(patient.age, equals(expectedAge));
      expect(patient.fullName, equals('Rahul Sharma'));
      expect(patient.initials, equals('RS'));
    });

    test('PatientRiskLevel and PatientStatus extension properties work properly', () {
      expect(PatientRiskLevel.high.displayName, equals('High Risk'));
      expect(PatientRiskLevel.medium.displayName, equals('Moderate Risk'));
      expect(PatientRiskLevel.low.displayName, equals('Low Risk'));

      expect(PatientStatus.active.displayName, equals('Active'));
      expect(PatientStatus.inactive.displayName, equals('Inactive'));
      expect(PatientStatus.archived.displayName, equals('Archived'));
      expect(PatientStatus.pendingReview.displayName, equals('Pending Review'));
    });
  });

  group('MockPatientRepository Tests', () {
    late MockPatientRepository repository;

    const testAdmin = UserModel(
      id: 'usr-admin',
      email: 'admin@clinic.com',
      firstName: 'Elena',
      lastName: 'Rostova',
      role: UserRole.administrator,
      permissions: UserPermissions(canInviteUsers: true),
    );

    setUp(() {
      repository = MockPatientRepository();
    });

    test('getPatients returns pre-populated list with at least 5 patients', () async {
      final patients = await repository.getPatients();
      expect(patients.length, greaterThanOrEqualTo(5));
    });

    test('getPatients filters by query properly', () async {
      final results = await repository.getPatients(query: 'Ananya');
      expect(results.length, equals(1));
      expect(results.first.firstName, equals('Ananya'));
    });

    test('getPatients filters by risk level properly', () async {
      final highRisk = await repository.getPatients(risk: PatientRiskLevel.high);
      expect(highRisk.every((p) => p.riskLevel == PatientRiskLevel.high), isTrue);
    });

    test('registerPatient adds a new patient with generated ID and number', () async {
      final newPatient = PatientModel(
        id: '',
        patientNumber: '',
        firstName: 'Divya',
        lastName: 'Menon',
        email: 'divya.menon@example.com',
        phone: '+91 91122 33445',
        dateOfBirth: DateTime(1996, 4, 12),
        gender: PatientGender.female,
        bloodGroup: 'B+',
        createdAt: DateTime.now(),
      );

      final registered = await repository.registerPatient(
        patient: newPatient,
        currentUser: testAdmin,
      );

      expect(registered.id, isNotEmpty);
      expect(registered.patientNumber, startsWith('PT-'));
      expect(registered.fullName, equals('Divya Menon'));

      final allPatients = await repository.getPatients();
      expect(allPatients.any((p) => p.id == registered.id), isTrue);
    });

    test('addClinicalNote records clinical note for patient', () async {
      final patients = await repository.getPatients();
      final targetPatient = patients.first;

      final note = await repository.addClinicalNote(
        patientId: targetPatient.id,
        title: 'Composite Filling Followup',
        content: 'No post-operative sensitivity reported. Marginal seal intact.',
        currentUser: testAdmin,
      );

      expect(note.title, equals('Composite Filling Followup'));
      expect(note.authorName, equals(testAdmin.fullName));

      final updated = await repository.getPatientById(targetPatient.id);
      expect(updated.clinicalNotes.any((n) => n.id == note.id), isTrue);
    });

    test('scheduleAppointment creates appointment record', () async {
      final patients = await repository.getPatients();
      final targetPatient = patients.first;
      final scheduleDate = DateTime.now().add(const Duration(days: 5));

      final apt = await repository.scheduleAppointment(
        patientId: targetPatient.id,
        date: scheduleDate,
        timeSlot: '11:00 AM - 11:45 AM',
        procedure: 'Laser Teeth Whitening',
        dentistName: 'Dr. Marcus Vance',
        currentUser: testAdmin,
      );

      expect(apt.procedure, equals('Laser Teeth Whitening'));
      expect(apt.status, equals('Scheduled'));

      final updated = await repository.getPatientById(targetPatient.id);
      expect(updated.appointments.any((a) => a.id == apt.id), isTrue);
    });

    test('getPatientStatistics calculates totals accurately', () async {
      final stats = await repository.getPatientStatistics();
      expect(stats.containsKey('totalPatients'), isTrue);
      expect(stats.containsKey('activePatients'), isTrue);
      expect(stats.containsKey('highRiskPatients'), isTrue);
      expect(stats.containsKey('insuredPatients'), isTrue);
      expect(stats['totalPatients'], greaterThanOrEqualTo(5));
    });
  });

  group('PatientBloc Tests', () {
    late MockPatientRepository repository;

    const testAdmin = UserModel(
      id: 'usr-admin',
      email: 'admin@clinic.com',
      firstName: 'Elena',
      lastName: 'Rostova',
      role: UserRole.administrator,
      permissions: UserPermissions(canInviteUsers: true),
    );

    setUp(() {
      repository = MockPatientRepository();
    });

    blocTest<PatientBloc, PatientState>(
      'emits [loading, success] when LoadPatientsRequested is added',
      build: () => PatientBloc(repository: repository),
      wait: const Duration(milliseconds: 1000),
      act: (bloc) => bloc.add(const LoadPatientsRequested()),
      expect: () => [
        const PatientState(status: Status.loading),
        predicate<PatientState>((state) {
          return state.status == Status.success &&
              state.patients.isNotEmpty &&
              state.filteredPatients.isNotEmpty &&
              state.statistics != null;
        }),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'filters patients dynamically on SearchQueryChanged',
      build: () => PatientBloc(repository: repository),
      seed: () {
        final samplePatients = [
          PatientModel(
            id: 'pat-001',
            patientNumber: 'PT-2026-0042',
            firstName: 'Ananya',
            lastName: 'Deshmukh',
            email: 'ananya@gmail.com',
            phone: '+91 98234 11223',
            dateOfBirth: DateTime(1994, 5, 14),
            gender: PatientGender.female,
            bloodGroup: 'O+',
            createdAt: DateTime.now(),
          ),
          PatientModel(
            id: 'pat-002',
            patientNumber: 'PT-2026-0043',
            firstName: 'Vikramaditya',
            lastName: 'Rao',
            email: 'vikram@gmail.com',
            phone: '+91 99887 66554',
            dateOfBirth: DateTime(1982, 11, 28),
            gender: PatientGender.male,
            bloodGroup: 'B+',
            createdAt: DateTime.now(),
          ),
        ];
        return PatientState(
          status: Status.success,
          patients: samplePatients,
          filteredPatients: samplePatients,
        );
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('Vikramaditya')),
      expect: () => [
        predicate<PatientState>((state) {
          return state.searchQuery == 'Vikramaditya' &&
              state.filteredPatients.length == 1 &&
              state.filteredPatients.first.firstName == 'Vikramaditya';
        }),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'registers new patient and emits success state with updated lists',
      build: () => PatientBloc(repository: repository),
      wait: const Duration(milliseconds: 1000),
      act: (bloc) => bloc.add(
        RegisterPatientSubmitted(
          patient: PatientModel(
            id: '',
            patientNumber: '',
            firstName: 'Naveen',
            lastName: 'Kumar',
            email: 'naveen.kumar@tech.in',
            phone: '+91 93344 55667',
            dateOfBirth: DateTime(1988, 9, 23),
            gender: PatientGender.male,
            bloodGroup: 'AB+',
            createdAt: DateTime.now(),
          ),
          currentUser: testAdmin,
        ),
      ),
      expect: () => [
        const PatientState(status: Status.loading),
        predicate<PatientState>((state) {
          return state.status == Status.success &&
              state.isFormSuccess == true &&
              state.patients.any((p) => p.firstName == 'Naveen');
        }),
      ],
    );

    blocTest<PatientBloc, PatientState>(
      'adds clinical note and updates selected patient profile in memory',
      build: () => PatientBloc(repository: repository),
      seed: () {
        final samplePatient = PatientModel(
          id: 'pat-001',
          patientNumber: 'PT-2026-0042',
          firstName: 'Ananya',
          lastName: 'Deshmukh',
          email: 'ananya@gmail.com',
          phone: '+91 98234 11223',
          dateOfBirth: DateTime(1994, 5, 14),
          gender: PatientGender.female,
          bloodGroup: 'O+',
          createdAt: DateTime.now(),
        );
        return PatientState(
          status: Status.success,
          patients: [samplePatient],
          filteredPatients: [samplePatient],
          selectedPatient: samplePatient,
        );
      },
      wait: const Duration(milliseconds: 1000),
      act: (bloc) => bloc.add(
        const AddClinicalNoteSubmitted(
          patientId: 'pat-001',
          title: 'Diagnostic AI Verification',
          content: 'Verified AI finding #fnd-1. Restorative filling scheduled.',
          currentUser: testAdmin,
        ),
      ),
      expect: () => [
        predicate<PatientState>((state) => state.status == Status.loading),
        predicate<PatientState>((state) {
          return state.status == Status.success &&
              state.isActionSuccess == true &&
              state.patients.isNotEmpty &&
              state.patients.first.clinicalNotes.any(
                    (n) => n.title == 'Diagnostic AI Verification',
                  );
        }),
      ],
    );
  });
}
