import 'package:equatable/equatable.dart';

class OnboardingFormData extends Equatable {
  // Step 1: Clinic Details
  final String clinicName;
  final String clinicType;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String website;

  // Step 2: Administrator Details
  final String adminFirstName;
  final String adminLastName;
  final String adminEmail;
  final String adminPhone;
  final String adminRole;

  // Step 3: Contact Details
  final String primaryContactName;
  final String primaryPhone;
  final String primaryEmail;
  final String alternatePhone;

  const OnboardingFormData({
    this.clinicName = '',
    this.clinicType = 'Multi-Speciality Practice',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = 'India',
    this.postalCode = '',
    this.website = '',
    this.adminFirstName = '',
    this.adminLastName = '',
    this.adminEmail = '',
    this.adminPhone = '',
    this.adminRole = 'Clinic Director / Owner',
    this.primaryContactName = '',
    this.primaryPhone = '',
    this.primaryEmail = '',
    this.alternatePhone = '',
  });

  OnboardingFormData copyWith({
    String? clinicName,
    String? clinicType,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? website,
    String? adminFirstName,
    String? adminLastName,
    String? adminEmail,
    String? adminPhone,
    String? adminRole,
    String? primaryContactName,
    String? primaryPhone,
    String? primaryEmail,
    String? alternatePhone,
  }) {
    return OnboardingFormData(
      clinicName: clinicName ?? this.clinicName,
      clinicType: clinicType ?? this.clinicType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      website: website ?? this.website,
      adminFirstName: adminFirstName ?? this.adminFirstName,
      adminLastName: adminLastName ?? this.adminLastName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPhone: adminPhone ?? this.adminPhone,
      adminRole: adminRole ?? this.adminRole,
      primaryContactName: primaryContactName ?? this.primaryContactName,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryEmail: primaryEmail ?? this.primaryEmail,
      alternatePhone: alternatePhone ?? this.alternatePhone,
    );
  }

  @override
  List<Object?> get props => [
        clinicName,
        clinicType,
        address,
        city,
        state,
        country,
        postalCode,
        website,
        adminFirstName,
        adminLastName,
        adminEmail,
        adminPhone,
        adminRole,
        primaryContactName,
        primaryPhone,
        primaryEmail,
        alternatePhone,
      ];
}
