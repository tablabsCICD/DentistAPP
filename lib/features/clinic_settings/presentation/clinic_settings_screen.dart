import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../../authentication/view_model/auth_bloc.dart';
import '../view_model/clinic_settings_bloc.dart';
import '../view_model/clinic_settings_event.dart';
import '../view_model/clinic_settings_state.dart';

class ClinicSettingsScreen extends StatefulWidget {
  const ClinicSettingsScreen({super.key});

  @override
  State<ClinicSettingsScreen> createState() => _ClinicSettingsScreenState();
}

class _ClinicSettingsScreenState extends State<ClinicSettingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedClinicType = 'Multi-Speciality Practice';

  // Operational Settings state
  String _selectedTimezone = 'UTC+05:30 (India Standard Time)';
  String _openingTime = '09:00';
  String _closingTime = '19:00';
  int _maxScansPerDay = 150;
  bool _enableReminders = true;
  bool _allowExport = false;

  bool _initializedWithData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _postalController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    context.read<ClinicSettingsBloc>().add(LoadClinicSettingsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateData(ClinicDetails clinic) {
    if (_initializedWithData) return;
    _nameController.text = clinic.name;
    _selectedClinicType = clinic.clinicType;
    _addressController.text = clinic.address;
    _cityController.text = clinic.city;
    _stateController.text = clinic.state;
    _countryController.text = clinic.country;
    _postalController.text = clinic.postalCode;
    _websiteController.text = clinic.website ?? '';
    _phoneController.text = clinic.primaryPhone;
    _emailController.text = clinic.primaryEmail;

    _selectedTimezone = clinic.operationalSettings.timezone;
    _openingTime = clinic.operationalSettings.openingTime;
    _closingTime = clinic.operationalSettings.closingTime;
    _maxScansPerDay = clinic.operationalSettings.maxAiScansPerDay;
    _enableReminders = clinic.operationalSettings.enableAutoAppointmentReminders;
    _allowExport = clinic.operationalSettings.allowStaffDataExport;

    _initializedWithData = true;
  }

  void _saveProfile(UserModel currentUser, ClinicDetails currentClinic) {
    if (_profileFormKey.currentState?.validate() ?? false) {
      final updatedClinic = currentClinic.copyWith(
        name: _nameController.text,
        clinicType: _selectedClinicType,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        postalCode: _postalController.text,
        website: _websiteController.text,
        primaryPhone: _phoneController.text,
        primaryEmail: _emailController.text,
      );

      context.read<ClinicSettingsBloc>().add(
            UpdateClinicProfileRequested(
              currentUser: currentUser,
              updatedClinic: updatedClinic,
            ),
          );
    }
  }

  void _saveOperationalSettings(UserModel currentUser) {
    final updatedSettings = OperationalSettings(
      timezone: _selectedTimezone,
      openingTime: _openingTime,
      closingTime: _closingTime,
      maxAiScansPerDay: _maxScansPerDay,
      enableAutoAppointmentReminders: _enableReminders,
      allowStaffDataExport: _allowExport,
    );

    context.read<ClinicSettingsBloc>().add(
          UpdateOperationalSettingsRequested(
            currentUser: currentUser,
            updatedSettings: updatedSettings,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user ??
        const UserModel(
          id: 'usr-admin-default',
          email: 'admin@clinic.com',
          firstName: 'Elena',
          lastName: 'Rostova',
          role: UserRole.administrator,
          permissions: UserPermissions(canEditClinicSettings: true),
        );

    final canEdit = authUser.permissions.canEditClinicSettings;

    return ResponsiveScaffold(
      title: 'Clinic Settings & Operations',
      currentRoute: RouteNames.clinicSettings,
      body: BlocConsumer<ClinicSettingsBloc, ClinicSettingsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.clinic == null) {
            return const AppLoading(message: 'Loading clinic settings...');
          }

          if (state.clinic != null) {
            _populateData(state.clinic!);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canEdit) ...[
                StatusCard(
                  title: 'Read-Only Mode: ${authUser.role.displayName}',
                  message:
                      'You are viewing clinical settings in read-only mode. Only Clinic Administrators have permission to modify operational policies and clinic profile coordinates.',
                  type: StatusType.info,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Settings Error',
                  message: state.errorMessage,
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.business_rounded), text: 'Clinic Profile'),
                  Tab(icon: Icon(Icons.tune_rounded), text: 'Operational & AI Rules'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: 620,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(canEdit, authUser, state.clinic, state.isLoading),
                    _buildOperationalTab(canEdit, authUser, state.isLoading),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(bool canEdit, UserModel user, ClinicDetails? clinic, bool isLoading) {
    return SingleChildScrollView(
      child: AppCard(
        padding: AppSpacing.paddingXl,
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clinic Profile Information', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text('Official practice details used on diagnostic reports and patient invoices.', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _nameController,
                label: 'Clinic Name *',
                enabled: canEdit && !isLoading,
                validator: AppValidators.clinicName,
              ),
              const SizedBox(height: AppSpacing.md),

              AppDropdown<String>(
                label: 'Clinic Specialization *',
                value: _selectedClinicType,
                enabled: canEdit && !isLoading,
                items: const [
                  DropdownMenuItem(value: 'Multi-Speciality Practice', child: Text('Multi-Speciality Practice')),
                  DropdownMenuItem(value: 'Solo Dental Practice', child: Text('Solo Dental Practice')),
                  DropdownMenuItem(value: 'Orthodontics Center', child: Text('Orthodontics Center')),
                  DropdownMenuItem(value: 'Oral Surgery & Hospital Unit', child: Text('Oral Surgery & Hospital Unit')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedClinicType = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _addressController,
                label: 'Address *',
                enabled: canEdit && !isLoading,
                validator: (v) => AppValidators.requiredField(v, 'Address'),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      label: 'City *',
                      enabled: canEdit && !isLoading,
                      validator: (v) => AppValidators.requiredField(v, 'City'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State *',
                      enabled: canEdit && !isLoading,
                      validator: (v) => AppValidators.requiredField(v, 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: AppPhoneField(
                      controller: _phoneController,
                      label: 'Clinic Phone *',
                      enabled: canEdit && !isLoading,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppEmailField(
                      controller: _emailController,
                      label: 'Public Clinic Email *',
                      enabled: canEdit && !isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              if (canEdit && clinic != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    text: 'Save Clinic Profile',
                    isLoading: isLoading,
                    width: 200,
                    icon: Icons.save_rounded,
                    onPressed: () => _saveProfile(user, clinic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationalTab(bool canEdit, UserModel user, bool isLoading) {
    return SingleChildScrollView(
      child: AppCard(
        padding: AppSpacing.paddingXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operational & AI Scanning Policies', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text('Configure practice timezone, daily capacity, and diagnostic access rules.', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.lg),

            AppDropdown<String>(
              label: 'Clinic Timezone *',
              value: _selectedTimezone,
              enabled: canEdit && !isLoading,
              items: const [
                DropdownMenuItem(value: 'UTC+05:30 (India Standard Time)', child: Text('UTC+05:30 (India Standard Time)')),
                DropdownMenuItem(value: 'UTC+00:00 (Greenwich Mean Time)', child: Text('UTC+00:00 (Greenwich Mean Time)')),
                DropdownMenuItem(value: 'UTC-05:00 (Eastern Time US)', child: Text('UTC-05:00 (Eastern Time US)')),
                DropdownMenuItem(value: 'UTC+04:00 (Gulf Standard Time)', child: Text('UTC+04:00 (Gulf Standard Time)')),
                DropdownMenuItem(value: 'UTC+08:00 (Singapore / HK)', child: Text('UTC+08:00 (Singapore / HK)')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedTimezone = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: TextEditingController(text: _openingTime),
                    label: 'Opening Time',
                    enabled: canEdit && !isLoading,
                    onChanged: (v) => _openingTime = v,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: TextEditingController(text: _closingTime),
                    label: 'Closing Time',
                    enabled: canEdit && !isLoading,
                    onChanged: (v) => _closingTime = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            SwitchListTile(
              title: const Text('Automated Patient Reminders'),
              subtitle: const Text('Dispatch SMS / WhatsApp appointment reminders before scheduled visits'),
              value: _enableReminders,
              onChanged: canEdit && !isLoading ? (v) => setState(() => _enableReminders = v) : null,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            SwitchListTile(
              title: const Text('Allow Staff Patient Record Export'),
              subtitle: const Text('Permit clinic staff members to download full patient radiological records'),
              value: _allowExport,
              onChanged: canEdit && !isLoading ? (v) => setState(() => _allowExport = v) : null,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xl),

            if (canEdit)
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryButton(
                  text: 'Save Operational Settings',
                  isLoading: isLoading,
                  width: 240,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => _saveOperationalSettings(user),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
