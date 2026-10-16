import 'package:equatable/equatable.dart';

enum ClinicStatus {
  pending,
  active,
  blocked,
}

extension ClinicStatusExtension on ClinicStatus {
  String get displayName {
    switch (this) {
      case ClinicStatus.pending:
        return 'Pending Activation';
      case ClinicStatus.active:
        return 'Active';
      case ClinicStatus.blocked:
        return 'Blocked / Suspended';
    }
  }

  String get code => name.toUpperCase();
}

enum InternalOnboardingStatus {
  setupIncomplete,
  verificationPending,
  subscriptionPending,
  paymentPending,
  complete,
}

extension InternalOnboardingStatusExtension on InternalOnboardingStatus {
  String get displayName {
    switch (this) {
      case InternalOnboardingStatus.setupIncomplete:
        return 'Setup Incomplete';
      case InternalOnboardingStatus.verificationPending:
        return 'Verification Pending';
      case InternalOnboardingStatus.subscriptionPending:
        return 'Subscription Required';
      case InternalOnboardingStatus.paymentPending:
        return 'Payment Pending';
      case InternalOnboardingStatus.complete:
        return 'Complete';
    }
  }
}

class OperationalSettings extends Equatable {
  final String timezone;
  final String openingTime;
  final String closingTime;
  final int maxAiScansPerDay;
  final bool enableAutoAppointmentReminders;
  final bool allowStaffDataExport;

  const OperationalSettings({
    this.timezone = 'UTC+05:30 (India Standard Time)',
    this.openingTime = '09:00',
    this.closingTime = '18:00',
    this.maxAiScansPerDay = 100,
    this.enableAutoAppointmentReminders = true,
    this.allowStaffDataExport = false,
  });

  OperationalSettings copyWith({
    String? timezone,
    String? openingTime,
    String? closingTime,
    int? maxAiScansPerDay,
    bool? enableAutoAppointmentReminders,
    bool? allowStaffDataExport,
  }) {
    return OperationalSettings(
      timezone: timezone ?? this.timezone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      maxAiScansPerDay: maxAiScansPerDay ?? this.maxAiScansPerDay,
      enableAutoAppointmentReminders:
          enableAutoAppointmentReminders ?? this.enableAutoAppointmentReminders,
      allowStaffDataExport: allowStaffDataExport ?? this.allowStaffDataExport,
    );
  }

  @override
  List<Object?> get props => [
        timezone,
        openingTime,
        closingTime,
        maxAiScansPerDay,
        enableAutoAppointmentReminders,
        allowStaffDataExport,
      ];
}

class ClinicDetails extends Equatable {
  final String id;
  final String name;
  final String clinicType;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? website;
  final String primaryContactName;
  final String primaryPhone;
  final String primaryEmail;
  final String? alternatePhone;
  final ClinicStatus status;
  final InternalOnboardingStatus onboardingStatus;
  final bool isEmailVerified;
  final bool isSubscriptionActive;
  final OperationalSettings operationalSettings;

  const ClinicDetails({
    required this.id,
    required this.name,
    required this.clinicType,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.website,
    required this.primaryContactName,
    required this.primaryPhone,
    required this.primaryEmail,
    this.alternatePhone,
    this.status = ClinicStatus.pending,
    this.onboardingStatus = InternalOnboardingStatus.setupIncomplete,
    this.isEmailVerified = false,
    this.isSubscriptionActive = false,
    this.operationalSettings = const OperationalSettings(),
  });

  ClinicDetails copyWith({
    String? id,
    String? name,
    String? clinicType,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? website,
    String? primaryContactName,
    String? primaryPhone,
    String? primaryEmail,
    String? alternatePhone,
    ClinicStatus? status,
    InternalOnboardingStatus? onboardingStatus,
    bool? isEmailVerified,
    bool? isSubscriptionActive,
    OperationalSettings? operationalSettings,
  }) {
    return ClinicDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      clinicType: clinicType ?? this.clinicType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      website: website ?? this.website,
      primaryContactName: primaryContactName ?? this.primaryContactName,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryEmail: primaryEmail ?? this.primaryEmail,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      status: status ?? this.status,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      operationalSettings: operationalSettings ?? this.operationalSettings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        clinicType,
        address,
        city,
        state,
        country,
        postalCode,
        website,
        primaryContactName,
        primaryPhone,
        primaryEmail,
        alternatePhone,
        status,
        onboardingStatus,
        isEmailVerified,
        isSubscriptionActive,
        operationalSettings,
      ];
}
