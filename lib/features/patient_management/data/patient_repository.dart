import '../../../core/errors/app_exception.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients({
    String? query,
    PatientStatus? status,
    PatientRiskLevel? risk,
    String? sortBy,
  });

  Future<PatientModel> getPatientById(String id);

  Future<PatientModel> registerPatient({
    required PatientModel patient,
    required UserModel currentUser,
  });

  Future<PatientModel> updatePatient({
    required PatientModel patient,
    required UserModel currentUser,
  });

  Future<bool> archivePatient({
    required String patientId,
    required UserModel currentUser,
  });

  Future<ClinicalNote> addClinicalNote({
    required String patientId,
    required String title,
    required String content,
    required UserModel currentUser,
  });

  Future<PatientAppointment> scheduleAppointment({
    required String patientId,
    required DateTime date,
    required String timeSlot,
    required String procedure,
    required String dentistName,
    required UserModel currentUser,
  });

  Future<Map<String, dynamic>> getPatientStatistics();
}

class MockPatientRepository implements PatientRepository {
  static final MockPatientRepository _instance = MockPatientRepository._internal();
  factory MockPatientRepository() => _instance;

  static late List<PatientModel> _sharedPatients;
  static bool _isInitialized = false;

  MockPatientRepository._internal() {
    if (!_isInitialized) {
      resetToInitial();
    }
  }

  static void resetToInitial() {
    _sharedPatients = [
      PatientModel(
        id: 'pat-001',
        patientNumber: 'PT-2026-0042',
        firstName: 'Ananya',
        lastName: 'Deshmukh',
        email: 'ananya.deshmukh@gmail.com',
        phone: '+91 98234 11223',
        dateOfBirth: DateTime(1994, 5, 14),
        gender: PatientGender.female,
        bloodGroup: 'O+',
        address: '74 Coral Heights, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560038',
        emergencyContactName: 'Rahul Deshmukh',
        emergencyContactPhone: '+91 98234 99887',
        emergencyRelationship: 'Spouse',
        allergies: const ['Penicillin', 'Sulfa Drugs'],
        chronicConditions: const ['Mild Asthma'],
        currentMedications: const ['Salbutamol Inhaler (PRN)'],
        chiefComplaint: 'Sensitivity in upper right premolar and routine dental prophylaxis.',
        riskLevel: PatientRiskLevel.medium,
        status: PatientStatus.active,
        insuranceProvider: 'Star Health Dental Plus',
        insurancePolicyNumber: 'SH-DT-994821',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 7)),
        totalAiScans: 4,
        recentAiRiskScore: 78,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        teethRecords: const [
          ToothRecord(toothNumber: 14, condition: ToothCondition.caries, notes: 'Class II occlusal-distal lesion detected by AI', surface: 'Distal-Occlusal'),
          ToothRecord(toothNumber: 16, condition: ToothCondition.treated, notes: 'Composite restoration (2025) intact', surface: 'Occlusal'),
          ToothRecord(toothNumber: 36, condition: ToothCondition.rootCanal, notes: 'RCT with porcelain fused to metal crown'),
          ToothRecord(toothNumber: 46, condition: ToothCondition.healthy),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-101',
            scanDate: DateTime.now().subtract(const Duration(days: 14)),
            scanType: 'Bitewing X-Ray (Right Quad)',
            overallHealthScore: 78,
            summary: 'Localized enamel demineralization on Tooth #14 distal edge with 92% AI diagnostic confidence.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-1',
                toothNumber: 14,
                findingType: 'Interproximal Caries',
                confidenceScore: 0.92,
                severity: PatientRiskLevel.medium,
                description: 'Sub-surface radiolucency in distal enamel margin of tooth 14 extending to dentino-enamel junction.',
                recommendation: 'Restorative composite restoration (Class II) indicated.',
              ),
              AiFinding(
                id: 'fnd-2',
                toothNumber: 15,
                findingType: 'Early Demineralization',
                confidenceScore: 0.86,
                severity: PatientRiskLevel.low,
                description: 'Incipient surface micro-pore loss in mesial enamel.',
                recommendation: 'High-fluoride remineralizing varnish treatment.',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-01',
            patientId: 'pat-001',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().add(const Duration(days: 7, hours: 2)),
            timeSlot: '10:30 AM - 11:15 AM',
            procedure: 'Class II Composite Filling #14',
            status: 'Scheduled',
            notes: 'Patient allergic to Penicillin. Use alternative antibiotic if prophylaxis needed.',
          ),
          PatientAppointment(
            id: 'apt-00',
            patientId: 'pat-001',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().subtract(const Duration(days: 14)),
            timeSlot: '02:00 PM - 02:45 PM',
            procedure: 'Dental Exam & AI Radiograph Scan',
            status: 'Completed',
            notes: 'Comprehensive bitewings captured and processed.',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-01',
            patientId: 'pat-001',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 14)),
            title: 'AI Radiograph Review & Treatment Plan',
            content: 'Reviewed AI bitewing scan scn-101. Confirmed Class II carious lesion on 14-DO. Scheduled for composite restoration under local anesthesia. Noted Penicillin allergy.',
            isFlagged: true,
          ),
          ClinicalNote(
            id: 'not-02',
            patientId: 'pat-001',
            authorName: 'Sarah Jenkins',
            authorRole: 'Clinic Staff',
            date: DateTime.now().subtract(const Duration(days: 14, hours: 2)),
            title: 'Insurance Pre-Authorization',
            content: 'Star Health pre-auth submitted for conservative restorative procedures. Approval reference #STAR-99214 confirmed.',
          ),
        ],
      ),
      PatientModel(
        id: 'pat-002',
        patientNumber: 'PT-2026-0043',
        firstName: 'Vikramaditya',
        lastName: 'Rao',
        email: 'vikram.rao@techcorp.in',
        phone: '+91 99887 66554',
        dateOfBirth: DateTime(1982, 11, 28),
        gender: PatientGender.male,
        bloodGroup: 'B+',
        address: '12 Palm Meadows, Whitefield',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560066',
        emergencyContactName: 'Geetha Rao',
        emergencyContactPhone: '+91 99887 11223',
        emergencyRelationship: 'Sister',
        allergies: const ['Latex'],
        chronicConditions: const ['Hypertension (Stage 1)'],
        currentMedications: const ['Amlodipine 5mg OD'],
        chiefComplaint: 'Severe throbbing pain in lower left molar, exacerbated by hot drinks.',
        riskLevel: PatientRiskLevel.high,
        status: PatientStatus.active,
        insuranceProvider: 'Max Bupa Health Care',
        insurancePolicyNumber: 'MB-DENT-88412',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 2)),
        totalAiScans: 6,
        recentAiRiskScore: 94,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        teethRecords: const [
          ToothRecord(toothNumber: 36, condition: ToothCondition.periodontalIssue, notes: 'Periapical lucency with deep carious pulp involvement'),
          ToothRecord(toothNumber: 18, condition: ToothCondition.missing, notes: 'Extracted in 2021'),
          ToothRecord(toothNumber: 28, condition: ToothCondition.missing, notes: 'Extracted in 2021'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-102',
            scanDate: DateTime.now().subtract(const Duration(days: 3)),
            scanType: 'Panoramic OPG Full Arch',
            overallHealthScore: 62,
            summary: 'Deep pulpal caries in tooth 36 with active periapical pathology. Urgent endodontic therapy indicated.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-3',
                toothNumber: 36,
                findingType: 'Pulpal Involvement / Periapical Lucency',
                confidenceScore: 0.97,
                severity: PatientRiskLevel.high,
                description: 'Large radiolucency invading pulp chamber and distal root apex radiolucency indicative of acute apical abscess/periodontitis.',
                recommendation: 'Immediate Root Canal Treatment (RCT) followed by ceramic crown.',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-02',
            patientId: 'pat-002',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().add(const Duration(days: 2, hours: 4)),
            timeSlot: '03:00 PM - 04:00 PM',
            procedure: 'Endodontic Canal Cleaning & Shaping #36 (Step 1)',
            status: 'Scheduled',
            notes: 'Latex allergy strictly observed - use non-latex dam.',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-03',
            patientId: 'pat-002',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 3)),
            title: 'Emergency Consult - Acute Irreversible Pulpitis #36',
            content: 'Patient presented with severe nocturnal pain. Vitality test negative on 36. Cold test produced prolonged intense lingering ache. Prescribed analgesics and non-latex protocol logged.',
            isFlagged: true,
          ),
        ],
      ),
      PatientModel(
        id: 'pat-003',
        patientNumber: 'PT-2026-0044',
        firstName: 'Kavita',
        lastName: 'Mehta',
        email: 'kavita.mehta@sunrise.org',
        phone: '+91 97112 33445',
        dateOfBirth: DateTime(1999, 8, 21),
        gender: PatientGender.female,
        bloodGroup: 'A+',
        address: '502 Skylark Apts, Koramangala',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560034',
        emergencyContactName: 'Manish Mehta',
        emergencyContactPhone: '+91 97112 99001',
        emergencyRelationship: 'Father',
        allergies: const [],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Consultation for clear aligner orthodontic therapy & aesthetic smile contouring.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.active,
        insuranceProvider: 'HDFC ERGO Health',
        insurancePolicyNumber: 'HDFC-D-55102',
        isInsuranceActive: true,
        assignedDentistId: 'usr-04',
        assignedDentistName: 'Dr. Arjun Patel',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 25)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 12)),
        totalAiScans: 3,
        recentAiRiskScore: 92,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        teethRecords: const [
          ToothRecord(toothNumber: 11, condition: ToothCondition.healthy, notes: 'Mild rotation'),
          ToothRecord(toothNumber: 21, condition: ToothCondition.healthy, notes: 'Mild crowding'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-103',
            scanDate: DateTime.now().subtract(const Duration(days: 25)),
            scanType: '3D Orthodontic Smile Analysis',
            overallHealthScore: 94,
            summary: 'Excellent bone support and periodontal status. Mild anterior crowding amenable to clear aligners.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Arjun Patel',
            findings: const [
              AiFinding(
                id: 'fnd-4',
                toothNumber: 21,
                findingType: 'Orthodontic Rotation',
                confidenceScore: 0.95,
                severity: PatientRiskLevel.low,
                description: '12-degree distal rotation of upper left central incisor.',
                recommendation: 'Clear aligner series (approx 14 aligner trays estimated).',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-03',
            patientId: 'pat-003',
            dentistName: 'Dr. Arjun Patel',
            date: DateTime.now().add(const Duration(days: 12, hours: 1)),
            timeSlot: '11:00 AM - 12:00 PM',
            procedure: 'Aligner Tray Delivery & Attachment Placement',
            status: 'Scheduled',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-04',
            patientId: 'pat-003',
            authorName: 'Dr. Arjun Patel',
            authorRole: 'Orthodontist',
            date: DateTime.now().subtract(const Duration(days: 25)),
            title: 'Aligner ClinCheck Staging Completed',
            content: '3D simulation approved. Predicted treatment duration: 7 months with bi-weekly tray changes.',
          ),
        ],
      ),
      PatientModel(
        id: 'pat-004',
        patientNumber: 'PT-2026-0045',
        firstName: 'Rohan',
        lastName: 'Nambiar',
        email: 'rohan.nambiar@apexcorp.com',
        phone: '+91 98450 77889',
        dateOfBirth: DateTime(1968, 3, 10),
        gender: PatientGender.male,
        bloodGroup: 'AB+',
        address: '88 Lavelle Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
        emergencyContactName: 'Sunita Nambiar',
        emergencyContactPhone: '+91 98450 11229',
        emergencyRelationship: 'Spouse',
        allergies: const ['Local Anesthetics (Epinephrine sensitivity)'],
        chronicConditions: const ['Type 2 Diabetes (HbA1c 6.8%)', 'Hyperlipidemia'],
        currentMedications: const ['Metformin 500mg BD', 'Atorvastatin 10mg HS'],
        chiefComplaint: 'Implant crown seating review and generalized bleeding gums upon brushing.',
        riskLevel: PatientRiskLevel.high,
        status: PatientStatus.active,
        insuranceProvider: 'Religare Care Dental',
        insurancePolicyNumber: 'REL-DT-33829',
        isInsuranceActive: false,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 40)),
        nextAppointmentDate: null,
        totalAiScans: 5,
        recentAiRiskScore: 71,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        teethRecords: const [
          ToothRecord(toothNumber: 46, condition: ToothCondition.implant, notes: 'Titanium implant integrated with zirconia crown'),
          ToothRecord(toothNumber: 31, condition: ToothCondition.periodontalIssue, notes: 'Generalized marginal gingivitis'),
          ToothRecord(toothNumber: 41, condition: ToothCondition.periodontalIssue, notes: 'Plaque retention & subgingival calculus'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-104',
            scanDate: DateTime.now().subtract(const Duration(days: 40)),
            scanType: 'Periapical & Periodontal Radiograph',
            overallHealthScore: 71,
            summary: 'Stable implant osseointegration at tooth 46. Moderate horizontal bone loss in lower anterior region.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-5',
                toothNumber: 31,
                findingType: 'Subgingival Calculus & Marginal Bone Loss',
                confidenceScore: 0.91,
                severity: PatientRiskLevel.medium,
                description: 'Calculus spur visible on mesial surface with 3mm bone reduction.',
                recommendation: 'Full mouth ultrasonic scaling, root planing and chlorhexidine irrigation.',
              ),
            ],
          ),
        ],
        appointments: const [],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-05',
            patientId: 'pat-004',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 40)),
            title: 'Periodontal Evaluation & Implant Check',
            content: 'Implant 46 stable with zero mobility. Gingival bleeding index elevated at 28%. Advised strict glycemic control and interdental flossing.',
            isFlagged: true,
          ),
        ],
      ),
      PatientModel(
        id: 'pat-005',
        patientNumber: 'PT-2026-0046',
        firstName: 'Zoya',
        lastName: 'Qureshi',
        email: 'zoya.qureshi@craftstudio.in',
        phone: '+91 96200 44556',
        dateOfBirth: DateTime(2017, 12, 5),
        gender: PatientGender.female,
        bloodGroup: 'O-',
        address: '24 Richmond Circle',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560025',
        emergencyContactName: 'Farhan Qureshi',
        emergencyContactPhone: '+91 96200 88990',
        emergencyRelationship: 'Father',
        allergies: const [],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Pediatric preventive checkup and pit & fissure sealants.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.active,
        insuranceProvider: 'Bajaj Allianz Family Dental',
        insurancePolicyNumber: 'BA-PED-44109',
        isInsuranceActive: true,
        assignedDentistId: 'usr-04',
        assignedDentistName: 'Dr. Arjun Patel',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 60)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 30)),
        totalAiScans: 2,
        recentAiRiskScore: 98,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        teethRecords: const [
          ToothRecord(toothNumber: 55, condition: ToothCondition.healthy),
          ToothRecord(toothNumber: 65, condition: ToothCondition.healthy),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-105',
            scanDate: DateTime.now().subtract(const Duration(days: 60)),
            scanType: 'Pediatric Bitewing',
            overallHealthScore: 98,
            summary: 'Zero active carious lesions detected. Normal primary dentition eruption sequence.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Arjun Patel',
            findings: const [],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-05',
            patientId: 'pat-005',
            dentistName: 'Dr. Arjun Patel',
            date: DateTime.now().add(const Duration(days: 30, hours: 2)),
            timeSlot: '04:30 PM - 05:00 PM',
            procedure: '6-Month Pediatric Fluoride Application',
            status: 'Scheduled',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-06',
            patientId: 'pat-005',
            authorName: 'Dr. Arjun Patel',
            authorRole: 'Dentist',
            date: DateTime.now().subtract(const Duration(days: 60)),
            title: 'Pediatric Preventive Sealants Completed',
            content: 'Applied resin pit and fissure sealants on primary molars 55, 65. Cooperative patient.',
          ),
        ],
      ),
      PatientModel(
        id: 'pat-006',
        patientNumber: 'PT-2026-0047',
        firstName: 'Tanvi',
        lastName: 'Kapoor',
        email: 'tanvi.kapoor@globaledge.com',
        phone: '+91 97400 11998',
        dateOfBirth: DateTime(1991, 7, 19),
        gender: PatientGender.female,
        bloodGroup: 'A-',
        address: '108 Embassy Golf Links',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560071',
        emergencyContactName: 'Sanjay Kapoor',
        emergencyContactPhone: '+91 97400 99881',
        emergencyRelationship: 'Spouse',
        allergies: const ['Aspirin / NSAIDs'],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Post-whitening sensitivity check and night guard fitting for bruxism.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.inactive,
        insuranceProvider: 'Cigna Global Health',
        insurancePolicyNumber: 'CG-IN-90812',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 120)),
        nextAppointmentDate: null,
        totalAiScans: 2,
        recentAiRiskScore: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        teethRecords: const [
          ToothRecord(toothNumber: 13, condition: ToothCondition.treated, notes: 'In-office laser bleaching completed'),
          ToothRecord(toothNumber: 23, condition: ToothCondition.treated, notes: 'In-office laser bleaching completed'),
        ],
        aiScans: const [],
        appointments: const [],
        clinicalNotes: const [],
      ),
    ];
    _isInitialized = true;
  }

  List<PatientModel> get _patients => _sharedPatients;

  @override
  Future<List<PatientModel>> getPatients({
    String? query,
    PatientStatus? status,
    PatientRiskLevel? risk,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    var results = List<PatientModel>.from(_patients);

    // Apply Search Query Filter
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((p) {
        return p.fullName.toLowerCase().contains(q) ||
            p.patientNumber.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q) ||
            p.phone.toLowerCase().contains(q) ||
            (p.assignedDentistName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Apply Status Filter
    if (status != null) {
      results = results.where((p) => p.status == status).toList();
    }

    // Apply Risk Filter
    if (risk != null) {
      results = results.where((p) => p.riskLevel == risk).toList();
    }

    // Apply Sorting
    if (sortBy != null) {
      switch (sortBy.toLowerCase()) {
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
    }

    return List.unmodifiable(results);
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final patient = _patients.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const NotFoundException('Patient record not found in system.'),
    );
    return patient;
  }

  @override
  Future<PatientModel> registerPatient({
    required PatientModel patient,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validation
    if (patient.firstName.trim().isEmpty || patient.lastName.trim().isEmpty) {
      throw const ValidationException('First and last names are mandatory.');
    }

    if (patient.phone.trim().isEmpty) {
      throw const ValidationException('Patient phone number is required.');
    }

    // Check duplicate phone/email (only against distinct non-empty values)
    final cleanPhone = patient.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final cleanEmail = patient.email.trim().toLowerCase();

    final exists = _patients.any((p) {
      final pPhone = p.phone.replaceAll(RegExp(r'[^\d+]'), '');
      final pEmail = p.email.trim().toLowerCase();

      final phoneMatch = cleanPhone.isNotEmpty && pPhone.isNotEmpty && cleanPhone == pPhone;
      final emailMatch = cleanEmail.isNotEmpty && pEmail.isNotEmpty && cleanEmail == pEmail;
      return phoneMatch || emailMatch;
    });

    if (exists) {
      throw const ValidationException('A patient with this email or phone number is already registered.');
    }

    final newPatientNumber = 'PT-${DateTime.now().year}-${(_patients.length + 42).toString().padLeft(4, '0')}';
    final newId = 'pat-${DateTime.now().millisecondsSinceEpoch}';

    final createdPatient = patient.copyWith(
      id: newId,
      patientNumber: newPatientNumber,
      createdAt: DateTime.now(),
      status: PatientStatus.active,
    );

    _patients.insert(0, createdPatient);
    return createdPatient;
  }

  @override
  Future<PatientModel> updatePatient({
    required PatientModel patient,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index == -1) {
      throw const NotFoundException('Cannot update non-existent patient.');
    }

    final cleanPhone = patient.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final cleanEmail = patient.email.trim().toLowerCase();

    final exists = _patients.any((p) {
      if (p.id == patient.id) return false;
      final pPhone = p.phone.replaceAll(RegExp(r'[^\d+]'), '');
      final pEmail = p.email.trim().toLowerCase();

      final phoneMatch = cleanPhone.isNotEmpty && pPhone.isNotEmpty && cleanPhone == pPhone;
      final emailMatch = cleanEmail.isNotEmpty && pEmail.isNotEmpty && cleanEmail == pEmail;
      return phoneMatch || emailMatch;
    });

    if (exists) {
      throw const ValidationException('Another patient with this email or phone number already exists.');
    }

    _patients[index] = patient;
    return _patients[index];
  }

  @override
  Future<bool> archivePatient({
    required String patientId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient record not found.');
    }

    _patients[index] = _patients[index].copyWith(status: PatientStatus.archived);
    return true;
  }

  @override
  Future<ClinicalNote> addClinicalNote({
    required String patientId,
    required String title,
    required String content,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw const ValidationException('Note title and clinical remarks cannot be blank.');
    }

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient not found.');
    }

    final newNote = ClinicalNote(
      id: 'not-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      authorName: currentUser.fullName,
      authorRole: currentUser.role.displayName,
      date: DateTime.now(),
      title: title.trim(),
      content: content.trim(),
      isFlagged: false,
    );

    final updatedNotes = List<ClinicalNote>.from(_patients[index].clinicalNotes)..insert(0, newNote);
    _patients[index] = _patients[index].copyWith(clinicalNotes: updatedNotes);

    return newNote;
  }

  @override
  Future<PatientAppointment> scheduleAppointment({
    required String patientId,
    required DateTime date,
    required String timeSlot,
    required String procedure,
    required String dentistName,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient record not found.');
    }

    final newAppointment = PatientAppointment(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      dentistName: dentistName,
      date: date,
      timeSlot: timeSlot,
      procedure: procedure,
      status: 'Scheduled',
    );

    final updatedAppointments = List<PatientAppointment>.from(_patients[index].appointments)..insert(0, newAppointment);
    _patients[index] = _patients[index].copyWith(
      appointments: updatedAppointments,
      nextAppointmentDate: date,
    );

    return newAppointment;
  }

  @override
  Future<Map<String, dynamic>> getPatientStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final total = _patients.length;
    final active = _patients.where((p) => p.status == PatientStatus.active).length;
    final highRisk = _patients.where((p) => p.riskLevel == PatientRiskLevel.high).length;
    final insured = _patients.where((p) => p.isInsuranceActive).length;

    return {
      'totalPatients': total,
      'activePatients': active,
      'highRiskPatients': highRisk,
      'insuredPatients': insured,
    };
  }
}
