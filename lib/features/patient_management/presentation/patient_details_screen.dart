import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../data/patient_repository.dart';
import '../view_model/patient_bloc.dart';
import '../view_model/patient_event.dart';
import '../view_model/patient_state.dart';
import 'widgets/add_clinical_note_dialog.dart';
import 'widgets/ai_scan_card.dart';
import 'widgets/dental_chart_view.dart';
import 'widgets/schedule_appointment_dialog.dart';

class PatientDetailsScreen extends StatelessWidget {
  final PatientModel patient;
  final UserModel? currentUser;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc(
        repository: MockPatientRepository(),
      )..add(SelectPatientRequested(patient.id)),
      child: _PatientDetailsView(
        initialPatient: patient,
        currentUser: currentUser,
      ),
    );
  }
}

class _PatientDetailsView extends StatefulWidget {
  final PatientModel initialPatient;
  final UserModel? currentUser;

  const _PatientDetailsView({
    required this.initialPatient,
    this.currentUser,
  });

  @override
  State<_PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<_PatientDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserModel _defaultUser = const UserModel(
    id: 'usr-01',
    email: 'admin@apexdental.com',
    firstName: 'Elena',
    lastName: 'Rostova',
    role: UserRole.administrator,
    permissions: UserPermissions(canInviteUsers: true),
  );

  UserModel get _activeUser => widget.currentUser ?? _defaultUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddNoteDialog(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AddClinicalNoteDialog(
        patientName: patient.fullName,
        onSave: (title, content) {
          context.read<PatientBloc>().add(
                AddClinicalNoteSubmitted(
                  patientId: patient.id,
                  title: title,
                  content: content,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openScheduleDialog(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ScheduleAppointmentDialog(
        patientName: patient.fullName,
        defaultDentist: patient.assignedDentistName,
        onSchedule: (date, slot, procedure, dentist) {
          context.read<PatientBloc>().add(
                ScheduleAppointmentSubmitted(
                  patientId: patient.id,
                  date: date,
                  timeSlot: slot,
                  procedure: procedure,
                  dentistName: dentist,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _confirmArchivePatient(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ConfirmationDialog(
        title: 'Archive Patient Record',
        message: 'Are you sure you want to archive ${patient.fullName} (${patient.patientNumber})? The record will remain accessible under archived filters.',
        confirmText: 'Archive Record',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(dialogCtx).pop();
          context.read<PatientBloc>().add(
                ArchivePatientRequested(
                  patientId: patient.id,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: 'Patient Profile',
      currentRoute: RouteNames.patients,
      showDrawer: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Patients',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == Status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
            );
          }
          if (state.isActionSuccess && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          final patient = state.selectedPatient ?? widget.initialPatient;

          if (state.status == Status.loading && state.selectedPatient == null) {
            return const Center(child: AppLoading(message: 'Loading patient records...'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderHero(context, patient, isDesktop),
              const SizedBox(height: AppSpacing.lg),
              _buildTabBar(),
              const SizedBox(height: AppSpacing.lg),
              _buildTabContent(context, patient, isDesktop),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderHero(BuildContext context, PatientModel patient, bool isDesktop) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  patient.initials,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            patient.fullName,
                            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            patient.patientNumber,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: patient.status.color.withAlpha(25),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(color: patient.status.color.withAlpha(60)),
                          ),
                          child: Text(
                            patient.status.displayName,
                            style: AppTypography.labelSmall.copyWith(
                              color: patient.status.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${patient.age} yrs (${DateFormat('MMM dd, yyyy').format(patient.dateOfBirth)})',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        Text('•', style: TextStyle(color: AppColors.textTertiary)),
                        Text(
                          patient.gender.displayName,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        Text('•', style: TextStyle(color: AppColors.textTertiary)),
                        Text(
                          'Blood: ${patient.bloodGroup}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Text('•', style: TextStyle(color: AppColors.textTertiary)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone, size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              patient.phone,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (patient.allergies.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: AppSpacing.borderRadiusSm,
                          border: Border.all(color: AppColors.error.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'CRITICAL ALLERGY ALERT: ${patient.allergies.join(", ")}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildRiskIndicator(patient.riskLevel),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Action Toolbar
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openScheduleDialog(context, patient),
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openAddNoteDialog(context, patient),
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('Add Note'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final bloc = context.read<PatientBloc>();
                  final result = await Navigator.of(context).pushNamed(
                    RouteNames.editPatient,
                    arguments: patient,
                  );
                  if (result == true) {
                    bloc.add(SelectPatientRequested(patient.id));
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Profile'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmArchivePatient(context, patient),
                icon: const Icon(Icons.archive_outlined, size: 16),
                label: const Text('Archive'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(PatientRiskLevel risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: risk.containerColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: risk.color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: risk.color, size: 24),
          const SizedBox(height: 2),
          Text(
            risk.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: risk.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.badge_outlined), text: 'Medical Overview'),
          Tab(icon: Icon(Icons.psychology_alt_outlined), text: 'AI Vision Insights'),
          Tab(icon: Icon(Icons.grid_view_rounded), text: 'Dental Odontogram'),
          Tab(icon: Icon(Icons.event_available_rounded), text: 'Appointments & Visits'),
          Tab(icon: Icon(Icons.speaker_notes_outlined), text: 'Clinical Notes'),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, PatientModel patient, bool isDesktop) {
    return SizedBox(
      height: 650,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(patient, isDesktop),
          _buildAiVisionTab(patient),
          _buildOdontogramTab(patient),
          _buildAppointmentsTab(context, patient),
          _buildClinicalNotesTab(context, patient),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PatientModel patient, bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Chief Complaint & Medical Alerts
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Chief Dental Complaint', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  patient.chiefComplaint.isNotEmpty ? patient.chiefComplaint : 'Routine comprehensive dental checkup and prophylactic cleaning.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Row 2: Medical Details & Insurance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chronic Medical Conditions', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      if (patient.chronicConditions.isEmpty)
                        Text('None reported by patient.', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary))
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: patient.chronicConditions
                              .map((c) => Chip(
                                    label: Text(c, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: AppColors.warningContainer,
                                    side: BorderSide(color: AppColors.warning.withAlpha(80)),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Current Prescribed Medications', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      if (patient.currentMedications.isEmpty)
                        Text('No active regular medications.', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary))
                      else
                        Text(
                          patient.currentMedications.join(' • '),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Insurance Coverage', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: patient.isInsuranceActive ? AppColors.successContainer : AppColors.surfaceVariant,
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                            child: Text(
                              patient.isInsuranceActive ? 'ACTIVE POLICY' : 'SELF PAY',
                              style: AppTypography.labelSmall.copyWith(
                                color: patient.isInsuranceActive ? AppColors.success : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        patient.insuranceProvider ?? 'No private insurance provider registered.',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (patient.insurancePolicyNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Policy ID: ${patient.insurancePolicyNumber}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Text('Assigned Attending Practitioner', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        patient.assignedDentistName ?? 'Unassigned Dental Practitioner',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Row 3: Address & Emergency Contact
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Residential Address', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${patient.address}, ${patient.city}, ${patient.state} - ${patient.postalCode}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Contact', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${patient.emergencyContactName} (${patient.emergencyRelationship}) • ${patient.emergencyContactPhone}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiVisionTab(PatientModel patient) {
    if (patient.aiScans.isEmpty) {
      return const AppEmptyState(
        title: 'No AI Radiograph Scans Yet',
        message: 'Upload bitewing, panoramic OPG, or periapical x-rays to generate instant AI pathology detections.',
        icon: Icons.psychology_alt_outlined,
      );
    }

    return ListView.separated(
      itemCount: patient.aiScans.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final scan = patient.aiScans[index];
        return AiScanCard(scan: scan);
      },
    );
  }

  Widget _buildOdontogramTab(PatientModel patient) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DentalChartView(teethRecords: patient.teethRecords),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, PatientModel patient) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');

    if (patient.appointments.isEmpty) {
      return AppEmptyState(
        title: 'No Scheduled Appointments',
        message: 'Patient currently has no active or past appointment records.',
        actionText: 'Book Chair Appointment',
        onAction: () => _openScheduleDialog(context, patient),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Chair Sessions (${patient.appointments.length})',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openScheduleDialog(context, patient),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Visit'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patient.appointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final apt = patient.appointments[index];
              final isScheduled = apt.status == 'Scheduled';

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isScheduled ? AppColors.primaryContainer : AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(
                        isScheduled ? Icons.event_available_rounded : Icons.check_circle_outline_rounded,
                        color: isScheduled ? AppColors.primary : AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(apt.procedure, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isScheduled ? AppColors.primaryContainer : AppColors.successContainer,
                                  borderRadius: AppSpacing.borderRadiusSm,
                                ),
                                child: Text(
                                  apt.status,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isScheduled ? AppColors.primary : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dateFormat.format(apt.date)} • ${apt.timeSlot}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            'Attending Dentist: ${apt.dentistName}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                          ),
                          if (apt.notes != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Remarks: ${apt.notes}',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesTab(BuildContext context, PatientModel patient) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    if (patient.clinicalNotes.isEmpty) {
      return AppEmptyState(
        title: 'No Clinical Notes Recorded',
        message: 'Document diagnostic notes, restorative observations, and treatment records.',
        actionText: 'Add Clinical Note',
        onAction: () => _openAddNoteDialog(context, patient),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Practitioner Clinical Remarks (${patient.clinicalNotes.length})',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddNoteDialog(context, patient),
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('Add Clinical Note'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patient.clinicalNotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final note = patient.clinicalNotes[index];

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(note.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            if (note.isFlagged) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: AppSpacing.borderRadiusSm,
                                ),
                                child: Text(
                                  'FLAGGED',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          dateFormat.format(note.date),
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recorded by ${note.authorName} (${note.authorRole})',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      note.content,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
