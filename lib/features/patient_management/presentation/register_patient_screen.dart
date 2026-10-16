import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../data/patient_repository.dart';
import '../view_model/patient_bloc.dart';
import '../view_model/patient_event.dart';
import '../view_model/patient_state.dart';

class RegisterPatientScreen extends StatelessWidget {
  final PatientModel? patientToEdit;
  final UserModel? currentUser;

  const RegisterPatientScreen({
    super.key,
    this.patientToEdit,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc(
        repository: MockPatientRepository(),
      ),
      child: _RegisterPatientView(
        patientToEdit: patientToEdit,
        currentUser: currentUser,
      ),
    );
  }
}

class _RegisterPatientView extends StatefulWidget {
  final PatientModel? patientToEdit;
  final UserModel? currentUser;

  const _RegisterPatientView({
    this.patientToEdit,
    this.currentUser,
  });

  @override
  State<_RegisterPatientView> createState() => _RegisterPatientViewState();
}

class _RegisterPatientViewState extends State<_RegisterPatientView> {
  final _formKey = GlobalKey<FormState>();

  // Demographics Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelController;

  // Medical History Controllers
  late TextEditingController _chiefComplaintController;
  late TextEditingController _medicationsController;
  late TextEditingController _customAllergyController;

  // Insurance Controllers
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insurancePolicyController;

  DateTime _dateOfBirth = DateTime(1995, 1, 1);
  PatientGender _gender = PatientGender.male;
  String _bloodGroup = 'O+';
  PatientRiskLevel _riskLevel = PatientRiskLevel.low;
  bool _isInsuranceActive = false;
  String _assignedDentist = 'Dr. Marcus Vance';

  final List<String> _selectedAllergies = [];
  final List<String> _selectedConditions = [];

  final List<String> _commonAllergies = [
    'Penicillin',
    'Latex',
    'Local Anesthetics',
    'Sulfa Drugs',
    'Aspirin',
    'Codeine',
    'Metals / Nickel',
  ];

  final List<String> _commonConditions = [
    'Hypertension',
    'Type 2 Diabetes',
    'Asthma',
    'Cardiac Disease',
    'Bleeding Disorder',
    'Epilepsy',
    'Osteoporosis',
  ];

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _dentists = ['Dr. Marcus Vance', 'Dr. Arjun Patel', 'Dr. Elena Rostova'];

  @override
  void initState() {
    super.initState();
    final p = widget.patientToEdit;

    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _cityController = TextEditingController(text: p?.city ?? 'Bengaluru');
    _stateController = TextEditingController(text: p?.state ?? 'Karnataka');
    _postalCodeController = TextEditingController(text: p?.postalCode ?? '560001');
    _emergencyNameController = TextEditingController(text: p?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: p?.emergencyContactPhone ?? '');
    _emergencyRelController = TextEditingController(text: p?.emergencyRelationship ?? 'Spouse');

    _chiefComplaintController = TextEditingController(text: p?.chiefComplaint ?? '');
    _medicationsController = TextEditingController(text: p?.currentMedications.join(', ') ?? '');
    _customAllergyController = TextEditingController();

    _insuranceProviderController = TextEditingController(text: p?.insuranceProvider ?? '');
    _insurancePolicyController = TextEditingController(text: p?.insurancePolicyNumber ?? '');

    if (p != null) {
      _dateOfBirth = p.dateOfBirth;
      _gender = p.gender;
      _bloodGroup = p.bloodGroup;
      _riskLevel = p.riskLevel;
      _isInsuranceActive = p.isInsuranceActive;
      _assignedDentist = p.assignedDentistName ?? _dentists.first;
      _selectedAllergies.addAll(p.allergies);
      _selectedConditions.addAll(p.chronicConditions);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelController.dispose();
    _chiefComplaintController.dispose();
    _medicationsController.dispose();
    _customAllergyController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _dateOfBirth.year;
    if (now.month < _dateOfBirth.month || (now.month == _dateOfBirth.month && now.day < _dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = widget.currentUser ??
          const UserModel(
            id: 'usr-01',
            email: 'admin@apexdental.com',
            firstName: 'Elena',
            lastName: 'Rostova',
            role: UserRole.administrator,
            permissions: UserPermissions(canInviteUsers: true),
          );

      final medicationsList = _medicationsController.text
          .split(',')
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList();

      if (widget.patientToEdit != null) {
        final updated = widget.patientToEdit!.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          bloodGroup: _bloodGroup,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          emergencyRelationship: _emergencyRelController.text.trim(),
          allergies: _selectedAllergies,
          chronicConditions: _selectedConditions,
          currentMedications: medicationsList,
          chiefComplaint: _chiefComplaintController.text.trim(),
          riskLevel: _riskLevel,
          insuranceProvider: _insuranceProviderController.text.trim().isNotEmpty ? _insuranceProviderController.text.trim() : null,
          insurancePolicyNumber: _insurancePolicyController.text.trim().isNotEmpty ? _insurancePolicyController.text.trim() : null,
          isInsuranceActive: _isInsuranceActive,
          assignedDentistName: _assignedDentist,
        );

        context.read<PatientBloc>().add(
              UpdatePatientSubmitted(patient: updated, currentUser: user),
            );
      } else {
        final newPatient = PatientModel(
          id: '',
          patientNumber: '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          bloodGroup: _bloodGroup,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          emergencyRelationship: _emergencyRelController.text.trim(),
          allergies: _selectedAllergies,
          chronicConditions: _selectedConditions,
          currentMedications: medicationsList,
          chiefComplaint: _chiefComplaintController.text.trim(),
          riskLevel: _riskLevel,
          status: PatientStatus.active,
          insuranceProvider: _insuranceProviderController.text.trim().isNotEmpty ? _insuranceProviderController.text.trim() : null,
          insurancePolicyNumber: _insurancePolicyController.text.trim().isNotEmpty ? _insurancePolicyController.text.trim() : null,
          isInsuranceActive: _isInsuranceActive,
          assignedDentistName: _assignedDentist,
          createdAt: DateTime.now(),
        );

        context.read<PatientBloc>().add(
              RegisterPatientSubmitted(patient: newPatient, currentUser: user),
            );
      }
    }
  }

  void _handleCloseOrBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.patients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patientToEdit != null;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: isEdit ? 'Edit Patient Profile' : 'New Patient Registration',
      showDrawer: false,
      onBack: () => _handleCloseOrBack(context),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => _handleCloseOrBack(context),
        ),
      ],
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == Status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.isFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Patient record saved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pushReplacementNamed(RouteNames.patients);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isEdit),
                const SizedBox(height: AppSpacing.lg),

                // Section 1: Demographics
                _buildDemographicsSection(isDesktop),
                const SizedBox(height: AppSpacing.lg),

                // Section 2: Clinical & Medical History
                _buildMedicalHistorySection(isDesktop),
                const SizedBox(height: AppSpacing.lg),

                // Section 3: Insurance & Assignment
                _buildInsuranceSection(isDesktop),
                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                _buildActionButtons(isLoading),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isEdit) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(
            isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Update Patient Record' : 'Register New Patient',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Enter patient details, medical allergies, insurance, and attending practitioner.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemographicsSection(bool isDesktop) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('1. Personal & Contact Demographics', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Name row
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _firstNameController,
                    label: 'First Name *',
                    hint: 'e.g. Ananya',
                    validator: (val) => AppValidators.requiredField(val, 'First Name'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _lastNameController,
                    label: 'Last Name *',
                    hint: 'e.g. Deshmukh',
                    validator: (val) => AppValidators.requiredField(val, 'Last Name'),
                  ),
                ),
              ],
            )
          else ...[
            AppTextField(
              controller: _firstNameController,
              label: 'First Name *',
              hint: 'e.g. Ananya',
              validator: (val) => AppValidators.requiredField(val, 'First Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _lastNameController,
              label: 'Last Name *',
              hint: 'e.g. Deshmukh',
              validator: (val) => AppValidators.requiredField(val, 'Last Name'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Contact row
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: AppPhoneField(
                    controller: _phoneController,
                    label: 'Mobile Phone *',
                    hint: '+91 98765 43210',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppEmailField(
                    controller: _emailController,
                    label: 'Email Address (Optional)',
                    hint: 'patient@example.com',
                    customValidator: (val) {
                      if (val == null || val.trim().isEmpty) return null;
                      return AppValidators.email(val);
                    },
                  ),
                ),
              ],
            )
          else ...[
            AppPhoneField(
              controller: _phoneController,
              label: 'Mobile Phone *',
              hint: '+91 98765 43210',
            ),
            const SizedBox(height: AppSpacing.md),
            AppEmailField(
              controller: _emailController,
              label: 'Email Address (Optional)',
              hint: 'patient@example.com',
              customValidator: (val) {
                if (val == null || val.trim().isEmpty) return null;
                return AppValidators.email(val);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // DOB, Gender, Blood Group
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDobPicker(dateFormat),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppDropdown<PatientGender>(
                    label: 'Gender',
                    value: _gender,
                    items: PatientGender.values
                        .map((g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 1,
                  child: AppDropdown<String>(
                    label: 'Blood Group',
                    value: _bloodGroup,
                    items: _bloodGroups
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _bloodGroup = val);
                    },
                  ),
                ),
              ],
            )
          else ...[
            _buildDobPicker(dateFormat),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppDropdown<PatientGender>(
                    label: 'Gender',
                    value: _gender,
                    items: PatientGender.values
                        .map((g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppDropdown<String>(
                    label: 'Blood Group',
                    value: _bloodGroup,
                    items: _bloodGroups
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _bloodGroup = val);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Address
          AppTextField(
            controller: _addressController,
            label: 'Street Address',
            hint: 'Flat, Building, Street address',
          ),
          const SizedBox(height: AppSpacing.md),

          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Bengaluru',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'Karnataka',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hint: '560001',
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Bengaluru',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'Karnataka',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _postalCodeController,
              label: 'Postal Code',
              hint: '560001',
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Emergency Contact
          Text('Emergency Contact Details (Optional)', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),

          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _emergencyNameController,
                    label: 'Contact Name',
                    hint: 'e.g. Rahul Deshmukh',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPhoneField(
                    controller: _emergencyPhoneController,
                    label: 'Contact Phone',
                    hint: '+91 98765 43210',
                    customValidator: (val) {
                      if (val == null || val.trim().isEmpty) return null;
                      return AppValidators.phone(val);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _emergencyRelController,
                    label: 'Relationship',
                    hint: 'Spouse / Parent',
                  ),
                ),
              ],
            )
          else ...[
            AppTextField(
              controller: _emergencyNameController,
              label: 'Contact Name',
              hint: 'e.g. Rahul Deshmukh',
            ),
            const SizedBox(height: AppSpacing.md),
            AppPhoneField(
              controller: _emergencyPhoneController,
              label: 'Contact Phone',
              hint: '+91 98765 43210',
              customValidator: (val) {
                if (val == null || val.trim().isEmpty) return null;
                return AppValidators.phone(val);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emergencyRelController,
              label: 'Relationship',
              hint: 'Spouse / Parent',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDobPicker(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDateOfBirth,
          borderRadius: AppSpacing.borderRadiusSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dateFormat.format(_dateOfBirth)} ($_calculatedAge yrs)',
                  style: AppTypography.bodyMedium,
                ),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalHistorySection(bool isDesktop) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('2. Medical History & Dental Concerns', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _chiefComplaintController,
            label: 'Chief Dental Complaint',
            hint: 'Describe current symptoms, toothache location, or cosmetic goals...',
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),

          // Allergies selector chips
          Text('Known Medical Allergies', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              ..._commonAllergies.map((allergy) {
                final isSelected = _selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  selectedColor: AppColors.errorContainer,
                  checkmarkColor: AppColors.error,
                  side: BorderSide(color: isSelected ? AppColors.error : AppColors.border),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.error : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                );
              }),
              ..._selectedAllergies.where((a) => !_commonAllergies.contains(a)).map((customAllergy) {
                return Chip(
                  label: Text(customAllergy),
                  backgroundColor: AppColors.errorContainer,
                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.error),
                  onDeleted: () {
                    setState(() => _selectedAllergies.remove(customAllergy));
                  },
                  side: const BorderSide(color: AppColors.error),
                  labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _customAllergyController,
                  hint: 'Add other allergy (e.g. Iodine, NSAIDs)...',
                  onSubmitted: (val) {
                    final trimmed = val.trim();
                    if (trimmed.isNotEmpty && !_selectedAllergies.contains(trimmed)) {
                      setState(() {
                        _selectedAllergies.add(trimmed);
                        _customAllergyController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  final trimmed = _customAllergyController.text.trim();
                  if (trimmed.isNotEmpty && !_selectedAllergies.contains(trimmed)) {
                    setState(() {
                      _selectedAllergies.add(trimmed);
                      _customAllergyController.clear();
                    });
                  }
                },
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Chronic Conditions
          Text('Chronic Medical Conditions', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _commonConditions.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                selectedColor: AppColors.warningContainer,
                checkmarkColor: AppColors.warning,
                side: BorderSide(color: isSelected ? AppColors.warning : AppColors.border),
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.warning : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConditions.add(condition);
                    } else {
                      _selectedConditions.remove(condition);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _medicationsController,
            label: 'Current Medications (Comma Separated)',
            hint: 'e.g. Metformin 500mg, Amlodipine 5mg...',
          ),
          const SizedBox(height: AppSpacing.md),

          // Risk Level
          AppDropdown<PatientRiskLevel>(
            label: 'Initial Dental Risk Categorization',
            value: _riskLevel,
            items: PatientRiskLevel.values
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(r.displayName),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _riskLevel = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection(bool isDesktop) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('3. Insurance & Clinical Assignment', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          CheckboxListTile(
            title: const Text('Patient has Active Dental Insurance Coverage'),
            subtitle: const Text('Check to link policy details for pre-authorization and claims'),
            value: _isInsuranceActive,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _isInsuranceActive = val ?? false),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_isInsuranceActive) ...[
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _insuranceProviderController,
                      label: 'Insurance Provider / Payer',
                      hint: 'e.g. Star Health Dental Plus',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _insurancePolicyController,
                      label: 'Policy / Member ID',
                      hint: 'e.g. SH-DT-994821',
                    ),
                  ),
                ],
              )
            else ...[
              AppTextField(
                controller: _insuranceProviderController,
                label: 'Insurance Provider / Payer',
                hint: 'e.g. Star Health Dental Plus',
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _insurancePolicyController,
                label: 'Policy / Member ID',
                hint: 'e.g. SH-DT-994821',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],

          AppDropdown<String>(
            label: 'Assigned Attending Dentist',
            value: _assignedDentist,
            items: _dentists
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _assignedDentist = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                text: widget.patientToEdit != null ? 'Update Patient' : 'Register Patient',
                isLoading: isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => _handleCloseOrBack(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
                ),
                child: const Text('Cancel'),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _handleCloseOrBack(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: AppSpacing.md),
            PrimaryButton(
              text: widget.patientToEdit != null ? 'Update Patient' : 'Register Patient',
              isLoading: isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        );
      },
    );
  }
}
