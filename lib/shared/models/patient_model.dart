import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum PatientGender {
  male,
  female,
  other,
}

extension PatientGenderExtension on PatientGender {
  String get displayName {
    switch (this) {
      case PatientGender.male:
        return 'Male';
      case PatientGender.female:
        return 'Female';
      case PatientGender.other:
        return 'Other';
    }
  }

  static PatientGender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'm':
        return PatientGender.male;
      case 'female':
      case 'f':
        return PatientGender.female;
      default:
        return PatientGender.other;
    }
  }
}

enum PatientRiskLevel {
  low,
  medium,
  high,
}

extension PatientRiskLevelExtension on PatientRiskLevel {
  String get displayName {
    switch (this) {
      case PatientRiskLevel.low:
        return 'Low Risk';
      case PatientRiskLevel.medium:
        return 'Moderate Risk';
      case PatientRiskLevel.high:
        return 'High Risk';
    }
  }

  Color get color {
    switch (this) {
      case PatientRiskLevel.low:
        return AppColors.success;
      case PatientRiskLevel.medium:
        return AppColors.warning;
      case PatientRiskLevel.high:
        return AppColors.error;
    }
  }

  Color get containerColor {
    switch (this) {
      case PatientRiskLevel.low:
        return AppColors.successContainer;
      case PatientRiskLevel.medium:
        return AppColors.warningContainer;
      case PatientRiskLevel.high:
        return AppColors.errorContainer;
    }
  }

  static PatientRiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return PatientRiskLevel.high;
      case 'medium':
      case 'moderate':
        return PatientRiskLevel.medium;
      case 'low':
      default:
        return PatientRiskLevel.low;
    }
  }
}

enum PatientStatus {
  active,
  inactive,
  archived,
  pendingReview,
}

extension PatientStatusExtension on PatientStatus {
  String get displayName {
    switch (this) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.inactive:
        return 'Inactive';
      case PatientStatus.archived:
        return 'Archived';
      case PatientStatus.pendingReview:
        return 'Pending Review';
    }
  }

  Color get color {
    switch (this) {
      case PatientStatus.active:
        return AppColors.success;
      case PatientStatus.inactive:
        return AppColors.textTertiary;
      case PatientStatus.archived:
        return AppColors.error;
      case PatientStatus.pendingReview:
        return AppColors.info;
    }
  }

  static PatientStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return PatientStatus.active;
      case 'inactive':
        return PatientStatus.inactive;
      case 'archived':
        return PatientStatus.archived;
      case 'pendingreview':
      case 'pending':
        return PatientStatus.pendingReview;
      default:
        return PatientStatus.active;
    }
  }
}

enum ToothCondition {
  healthy,
  caries,
  treated,
  missing,
  crown,
  implant,
  rootCanal,
  periodontalIssue,
}

extension ToothConditionExtension on ToothCondition {
  String get displayName {
    switch (this) {
      case ToothCondition.healthy:
        return 'Healthy';
      case ToothCondition.caries:
        return 'Caries Detected';
      case ToothCondition.treated:
        return 'Restored / Filled';
      case ToothCondition.missing:
        return 'Missing';
      case ToothCondition.crown:
        return 'Crown Fitted';
      case ToothCondition.implant:
        return 'Dental Implant';
      case ToothCondition.rootCanal:
        return 'Root Canal Treated';
      case ToothCondition.periodontalIssue:
        return 'Periodontal Pocket';
    }
  }

  Color get badgeColor {
    switch (this) {
      case ToothCondition.healthy:
        return AppColors.success;
      case ToothCondition.caries:
        return AppColors.error;
      case ToothCondition.treated:
        return AppColors.info;
      case ToothCondition.missing:
        return AppColors.textTertiary;
      case ToothCondition.crown:
        return const Color(0xFF8B5CF6);
      case ToothCondition.implant:
        return const Color(0xFFF59E0B);
      case ToothCondition.rootCanal:
        return const Color(0xFFEC4899);
      case ToothCondition.periodontalIssue:
        return AppColors.warning;
    }
  }
}

class ToothRecord extends Equatable {
  final int toothNumber; // FDI numbering 1..32 or 11..48
  final ToothCondition condition;
  final String? surface; // Mesial, Distal, Occlusal, Lingual, Facial
  final String? notes;
  final DateTime? lastTreatedDate;

  const ToothRecord({
    required this.toothNumber,
    this.condition = ToothCondition.healthy,
    this.surface,
    this.notes,
    this.lastTreatedDate,
  });

  @override
  List<Object?> get props => [toothNumber, condition, surface, notes, lastTreatedDate];
}

class AiFinding extends Equatable {
  final String id;
  final int toothNumber;
  final String findingType; // e.g., 'Interproximal Caries', 'Bone Loss', 'Calculus'
  final double confidenceScore; // 0.0 to 1.0 (e.g. 0.94 -> 94%)
  final PatientRiskLevel severity;
  final String description;
  final String recommendation;

  const AiFinding({
    required this.id,
    required this.toothNumber,
    required this.findingType,
    required this.confidenceScore,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  int get confidencePercentage => (confidenceScore * 100).round();

  @override
  List<Object?> get props => [
        id,
        toothNumber,
        findingType,
        confidenceScore,
        severity,
        description,
        recommendation,
      ];
}

class AiScanRecord extends Equatable {
  final String id;
  final DateTime scanDate;
  final String scanType; // e.g., 'Panoramic OPG', 'Bitewing X-Ray', 'Periapical'
  final List<AiFinding> findings;
  final int overallHealthScore; // 0 to 100
  final String summary;
  final bool isReviewedByDentist;
  final String? reviewedByDentistName;

  const AiScanRecord({
    required this.id,
    required this.scanDate,
    required this.scanType,
    required this.findings,
    required this.overallHealthScore,
    required this.summary,
    this.isReviewedByDentist = false,
    this.reviewedByDentistName,
  });

  @override
  List<Object?> get props => [
        id,
        scanDate,
        scanType,
        findings,
        overallHealthScore,
        summary,
        isReviewedByDentist,
        reviewedByDentistName,
      ];
}

class ClinicalNote extends Equatable {
  final String id;
  final String patientId;
  final String authorName;
  final String authorRole;
  final DateTime date;
  final String title;
  final String content;
  final bool isFlagged;

  const ClinicalNote({
    required this.id,
    required this.patientId,
    required this.authorName,
    required this.authorRole,
    required this.date,
    required this.title,
    required this.content,
    this.isFlagged = false,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        authorName,
        authorRole,
        date,
        title,
        content,
        isFlagged,
      ];
}

class PatientAppointment extends Equatable {
  final String id;
  final String patientId;
  final String dentistName;
  final DateTime date;
  final String timeSlot;
  final String procedure;
  final String status; // 'Scheduled', 'Completed', 'Cancelled', 'In-Progress'
  final String? notes;

  const PatientAppointment({
    required this.id,
    required this.patientId,
    required this.dentistName,
    required this.date,
    required this.timeSlot,
    required this.procedure,
    this.status = 'Scheduled',
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        dentistName,
        date,
        timeSlot,
        procedure,
        status,
        notes,
      ];
}

class PatientModel extends Equatable {
  final String id;
  final String patientNumber; // e.g., 'PT-2026-0042'
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final PatientGender gender;
  final String bloodGroup; // 'A+', 'B+', 'O+', 'AB+', etc.
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyRelationship;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final String chiefComplaint;
  final PatientRiskLevel riskLevel;
  final PatientStatus status;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final bool isInsuranceActive;
  final String? assignedDentistId;
  final String? assignedDentistName;
  final DateTime? lastVisitDate;
  final DateTime? nextAppointmentDate;
  final int totalAiScans;
  final int? recentAiRiskScore; // 0 to 100
  final DateTime createdAt;
  final List<ToothRecord> teethRecords;
  final List<AiScanRecord> aiScans;
  final List<PatientAppointment> appointments;
  final List<ClinicalNote> clinicalNotes;

  const PatientModel({
    required this.id,
    required this.patientNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.address = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.emergencyRelationship = '',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.chiefComplaint = '',
    this.riskLevel = PatientRiskLevel.low,
    this.status = PatientStatus.active,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.isInsuranceActive = false,
    this.assignedDentistId,
    this.assignedDentistName,
    this.lastVisitDate,
    this.nextAppointmentDate,
    this.totalAiScans = 0,
    this.recentAiRiskScore,
    required this.createdAt,
    this.teethRecords = const [],
    this.aiScans = const [],
    this.appointments = const [],
    this.clinicalNotes = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  PatientModel copyWith({
    String? id,
    String? patientNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    PatientGender? gender,
    String? bloodGroup,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyRelationship,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    String? chiefComplaint,
    PatientRiskLevel? riskLevel,
    PatientStatus? status,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    bool? isInsuranceActive,
    String? assignedDentistId,
    String? assignedDentistName,
    DateTime? lastVisitDate,
    DateTime? nextAppointmentDate,
    int? totalAiScans,
    int? recentAiRiskScore,
    DateTime? createdAt,
    List<ToothRecord>? teethRecords,
    List<AiScanRecord>? aiScans,
    List<PatientAppointment>? appointments,
    List<ClinicalNote>? clinicalNotes,
  }) {
    return PatientModel(
      id: id ?? this.id,
      patientNumber: patientNumber ?? this.patientNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      isInsuranceActive: isInsuranceActive ?? this.isInsuranceActive,
      assignedDentistId: assignedDentistId ?? this.assignedDentistId,
      assignedDentistName: assignedDentistName ?? this.assignedDentistName,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      nextAppointmentDate: nextAppointmentDate ?? this.nextAppointmentDate,
      totalAiScans: totalAiScans ?? this.totalAiScans,
      recentAiRiskScore: recentAiRiskScore ?? this.recentAiRiskScore,
      createdAt: createdAt ?? this.createdAt,
      teethRecords: teethRecords ?? this.teethRecords,
      aiScans: aiScans ?? this.aiScans,
      appointments: appointments ?? this.appointments,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientNumber,
        firstName,
        lastName,
        email,
        phone,
        dateOfBirth,
        gender,
        bloodGroup,
        address,
        city,
        state,
        postalCode,
        emergencyContactName,
        emergencyContactPhone,
        emergencyRelationship,
        allergies,
        chronicConditions,
        currentMedications,
        chiefComplaint,
        riskLevel,
        status,
        insuranceProvider,
        insurancePolicyNumber,
        isInsuranceActive,
        assignedDentistId,
        assignedDentistName,
        lastVisitDate,
        nextAppointmentDate,
        totalAiScans,
        recentAiRiskScore,
        createdAt,
        teethRecords,
        aiScans,
        appointments,
        clinicalNotes,
      ];
}
