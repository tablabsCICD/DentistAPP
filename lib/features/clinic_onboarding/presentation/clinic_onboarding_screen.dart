import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../domain/onboarding_form_data.dart';
import '../view_model/clinic_onboarding_bloc.dart';
import '../view_model/clinic_onboarding_event.dart';
import '../view_model/clinic_onboarding_state.dart';

class ClinicOnboardingScreen extends StatefulWidget {
  const ClinicOnboardingScreen({super.key});

  @override
  State<ClinicOnboardingScreen> createState() => _ClinicOnboardingScreenState();
}

class _ClinicOnboardingScreenState extends State<ClinicOnboardingScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Controllers for Step 1
  late final TextEditingController _clinicNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _websiteController;
  String _selectedClinicType = 'Multi-Speciality Practice';

  // Controllers for Step 2
  late final TextEditingController _adminFirstNameController;
  late final TextEditingController _adminLastNameController;
  late final TextEditingController _adminEmailController;
  late final TextEditingController _adminPhoneController;
  String _selectedAdminRole = 'Clinic Director / Owner';

  // Controllers for Step 3
  late final TextEditingController _primaryContactNameController;
  late final TextEditingController _primaryPhoneController;
  late final TextEditingController _primaryEmailController;
  late final TextEditingController _alternatePhoneController;

  @override
  void initState() {
    super.initState();
    final data = context.read<ClinicOnboardingBloc>().state.formData;

    _clinicNameController = TextEditingController(text: data.clinicName.isNotEmpty ? data.clinicName : 'Apex Dental Center');
    _addressController = TextEditingController(text: data.address.isNotEmpty ? data.address : '42 Medical Enclave, MG Road');
    _cityController = TextEditingController(text: data.city.isNotEmpty ? data.city : 'Bengaluru');
    _stateController = TextEditingController(text: data.state.isNotEmpty ? data.state : 'Karnataka');
    _countryController = TextEditingController(text: data.country.isNotEmpty ? data.country : 'India');
    _postalCodeController = TextEditingController(text: data.postalCode.isNotEmpty ? data.postalCode : '560001');
    _websiteController = TextEditingController(text: data.website.isNotEmpty ? data.website : 'https://apexdental.com');
    _selectedClinicType = data.clinicType;

    _adminFirstNameController = TextEditingController(text: data.adminFirstName.isNotEmpty ? data.adminFirstName : 'Elena');
    _adminLastNameController = TextEditingController(text: data.adminLastName.isNotEmpty ? data.adminLastName : 'Rostova');
    _adminEmailController = TextEditingController(text: data.adminEmail.isNotEmpty ? data.adminEmail : 'elena.rostova@apexdental.com');
    _adminPhoneController = TextEditingController(text: data.adminPhone.isNotEmpty ? data.adminPhone : '+91 98765 43210');
    _selectedAdminRole = data.adminRole;

    _primaryContactNameController = TextEditingController(text: data.primaryContactName.isNotEmpty ? data.primaryContactName : 'Dr. Elena Rostova');
    _primaryPhoneController = TextEditingController(text: data.primaryPhone.isNotEmpty ? data.primaryPhone : '+91 98765 43210');
    _primaryEmailController = TextEditingController(text: data.primaryEmail.isNotEmpty ? data.primaryEmail : 'contact@apexdental.com');
    _alternatePhoneController = TextEditingController(text: data.alternatePhone.isNotEmpty ? data.alternatePhone : '+91 80 2345 6789');
  }

  @override
  void dispose() {
    _clinicNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _websiteController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _primaryContactNameController.dispose();
    _primaryPhoneController.dispose();
    _primaryEmailController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  void _saveCurrentStepToState() {
    final updatedData = OnboardingFormData(
      clinicName: _clinicNameController.text,
      clinicType: _selectedClinicType,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      postalCode: _postalCodeController.text,
      website: _websiteController.text,
      adminFirstName: _adminFirstNameController.text,
      adminLastName: _adminLastNameController.text,
      adminEmail: _adminEmailController.text,
      adminPhone: _adminPhoneController.text,
      adminRole: _selectedAdminRole,
      primaryContactName: _primaryContactNameController.text,
      primaryPhone: _primaryPhoneController.text,
      primaryEmail: _primaryEmailController.text,
      alternatePhone: _alternatePhoneController.text,
    );
    context.read<ClinicOnboardingBloc>().add(FormDataUpdated(updatedData));
  }

  void _onNextStep(int currentStep) {
    if (currentStep == 0) {
      if (!(_step1FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(const StepChanged(1));
    } else if (currentStep == 1) {
      if (!(_step2FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(const StepChanged(2));
    } else if (currentStep == 2) {
      if (!(_step3FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(SubmitOnboardingRequested());
    }
  }

  void _onPreviousStep(int currentStep) {
    if (currentStep > 0) {
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(StepChanged(currentStep - 1));
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicOnboardingBloc, ClinicOnboardingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pushReplacementNamed(RouteNames.emailVerification);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Clinic Registration & Onboarding'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => _onPreviousStep(state.currentStep),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Progress Indicator
                    _buildStepProgressIndicator(state.currentStep),
                    const SizedBox(height: AppSpacing.xl),

                    if (state.errorMessage != null) ...[
                      StatusCard(
                        title: 'Registration Error',
                        message: state.errorMessage,
                        type: StatusType.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    AppCard(
                      padding: AppSpacing.paddingXl,
                      child: _buildCurrentStepForm(state.currentStep, state.isLoading),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Actions (Back & Next)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: state.isLoading ? null : () => _onPreviousStep(state.currentStep),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(
                              state.currentStep == 0 ? 'Cancel to Login' : 'Back',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: PrimaryButton(
                            text: state.currentStep == 2 ? 'Submit Registration' : 'Next Step',
                            isLoading: state.isLoading,
                            icon: state.currentStep == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            onPressed: () => _onNextStep(state.currentStep),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepProgressIndicator(int currentStep) {
    final steps = ['Clinic Details', 'Administrator Details', 'Contact & Emergency'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        return Column(
          children: [
            Row(
              children: List.generate(steps.length, (index) {
                final isCompleted = currentStep > index;
                final isCurrent = currentStep == index;

                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : (isCurrent ? AppColors.primary : AppColors.surfaceVariant),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : AppColors.textTertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            steps[index],
                            style: AppTypography.labelSmall.copyWith(
                              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (index < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            color: isCompleted ? AppColors.success : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            if (isNarrow) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Step ${currentStep + 1} of ${steps.length}: ${steps[currentStep]}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCurrentStepForm(int step, bool isLoading) {
    switch (step) {
      case 0:
        return _buildStep1Form(isLoading);
      case 1:
        return _buildStep2Form(isLoading);
      case 2:
        return _buildStep3Form(isLoading);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Form(bool isLoading) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 1: Clinic Practice Information', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Enter the registered details of your dental facility.', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _clinicNameController,
            label: 'Clinic Name *',
            hint: 'e.g., Apex Dental Care',
            enabled: !isLoading,
            validator: AppValidators.clinicName,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Clinic Type *',
            value: _selectedClinicType,
            items: const [
              DropdownMenuItem(value: 'Multi-Speciality Practice', child: Text('Multi-Speciality Practice')),
              DropdownMenuItem(value: 'Solo Dental Practice', child: Text('Solo Dental Practice')),
              DropdownMenuItem(value: 'Orthodontics Center', child: Text('Orthodontics Center')),
              DropdownMenuItem(value: 'Oral Surgery & Hospital Unit', child: Text('Oral Surgery & Hospital Unit')),
              DropdownMenuItem(value: 'Pediatric Dental Center', child: Text('Pediatric Dental Center')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedClinicType = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _addressController,
            label: 'Street Address *',
            hint: 'e.g., 42 Medical Enclave, MG Road',
            enabled: !isLoading,
            validator: (v) => AppValidators.requiredField(v, 'Address'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _cityController,
                  label: 'City *',
                  hint: 'e.g., Bengaluru',
                  enabled: !isLoading,
                  validator: (v) => AppValidators.requiredField(v, 'City'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _stateController,
                  label: 'State / Province *',
                  hint: 'e.g., Karnataka',
                  enabled: !isLoading,
                  validator: (v) => AppValidators.requiredField(v, 'State'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _countryController,
                  label: 'Country *',
                  hint: 'e.g., India',
                  enabled: !isLoading,
                  validator: (v) => AppValidators.requiredField(v, 'Country'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code *',
                  hint: 'e.g., 560001',
                  enabled: !isLoading,
                  validator: AppValidators.postalCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _websiteController,
            label: 'Clinic Website (Optional)',
            hint: 'https://apexdental.com',
            enabled: !isLoading,
            validator: AppValidators.website,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form(bool isLoading) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 2: Administrator & Lead Practitioner', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Primary dental doctor or practice manager who will administer the SaaS tenant.', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _adminFirstNameController,
                  label: 'First Name *',
                  hint: 'e.g., Elena',
                  enabled: !isLoading,
                  validator: (v) => AppValidators.administratorName(v, 'First Name'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _adminLastNameController,
                  label: 'Last Name *',
                  hint: 'e.g., Rostova',
                  enabled: !isLoading,
                  validator: (v) => AppValidators.administratorName(v, 'Last Name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppEmailField(
            controller: _adminEmailController,
            label: 'Administrator Email *',
            hint: 'elena.rostova@apexdental.com',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          AppPhoneField(
            controller: _adminPhoneController,
            label: 'Mobile Number *',
            hint: '+91 98765 43210',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Role / Designation *',
            value: _selectedAdminRole,
            items: const [
              DropdownMenuItem(value: 'Clinic Director / Owner', child: Text('Clinic Director / Owner')),
              DropdownMenuItem(value: 'Lead Dental Surgeon', child: Text('Lead Dental Surgeon')),
              DropdownMenuItem(value: 'Practice Administrator', child: Text('Practice Administrator')),
              DropdownMenuItem(value: 'Chief Medical Officer', child: Text('Chief Medical Officer')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedAdminRole = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form(bool isLoading) {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 3: Contact & Emergency Information', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Public contact coordinates for patient booking and critical notifications.', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _primaryContactNameController,
            label: 'Primary Contact Person *',
            hint: 'e.g., Dr. Elena Rostova',
            enabled: !isLoading,
            validator: (v) => AppValidators.requiredField(v, 'Primary Contact Person'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPhoneField(
            controller: _primaryPhoneController,
            label: 'Primary Clinic Phone *',
            hint: '+91 98765 43210',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          AppEmailField(
            controller: _primaryEmailController,
            label: 'Primary Clinic Email *',
            hint: 'contact@apexdental.com',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          AppPhoneField(
            controller: _alternatePhoneController,
            label: 'Alternate / Landline Phone (Optional)',
            hint: '+91 80 2345 6789',
            enabled: !isLoading,
            customValidator: (v) => v == null || v.isEmpty ? null : AppValidators.phone(v),
          ),
        ],
      ),
    );
  }
}
