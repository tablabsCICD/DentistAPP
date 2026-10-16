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
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/feedback/status_badge.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../data/patient_repository.dart';
import '../view_model/patient_bloc.dart';
import '../view_model/patient_event.dart';
import '../view_model/patient_state.dart';
import 'widgets/add_clinical_note_dialog.dart';
import 'widgets/patient_summary_card.dart';

class PatientListScreen extends StatelessWidget {
  final UserModel? currentUser;

  const PatientListScreen({
    super.key,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc(
        repository: MockPatientRepository(),
      )..add(const LoadPatientsRequested()),
      child: _PatientListView(currentUser: currentUser),
    );
  }
}

class _PatientListView extends StatefulWidget {
  final UserModel? currentUser;

  const _PatientListView({this.currentUser});

  @override
  State<_PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<_PatientListView> {
  final TextEditingController _searchController = TextEditingController();
  final UserModel _defaultUser = const UserModel(
    id: 'usr-01',
    email: 'elena.rostova@apexdental.com',
    firstName: 'Elena',
    lastName: 'Rostova',
    role: UserRole.administrator,
    permissions: UserPermissions(
      canInviteUsers: true,
      canActivateUsers: true,
      canDeactivateUsers: true,
      canChangeUserRole: true,
      canEditClinicSettings: true,
      canManageSubscription: true,
    ),
  );

  UserModel get _activeUser => widget.currentUser ?? _defaultUser;

  @override
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: 'Patient Management',
      currentRoute: RouteNames.patients,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Patient Registry',
          onPressed: () => context.read<PatientBloc>().add(const LoadPatientsRequested()),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bloc = context.read<PatientBloc>();
          final result = await Navigator.of(context).pushNamed(RouteNames.registerPatient);
          if (result == true) {
            bloc.add(const LoadPatientsRequested());
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Register Patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
          if (state.isActionSuccess && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == Status.loading && state.patients.isEmpty) {
            return const Center(child: AppLoading(message: 'Loading patient records...'));
          }

          if (state.status == Status.error && state.patients.isEmpty) {
            return AppErrorState(
              title: 'Unable to Load Patients',
              message: state.errorMessage ?? 'An error occurred while fetching patients.',
              onRetry: () => context.read<PatientBloc>().add(const LoadPatientsRequested()),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDesktop, state),
              const SizedBox(height: AppSpacing.lg),
              _buildMetricsRow(state),
              const SizedBox(height: AppSpacing.lg),
              _buildFilterAndSearchControls(context, state),
              const SizedBox(height: AppSpacing.lg),
              if (state.filteredPatients.isEmpty)
                AppEmptyState(
                  title: 'No Patients Found',
                  message: state.searchQuery.isNotEmpty
                      ? 'No patient records matched "${state.searchQuery}". Try modifying your search or filter.'
                      : 'No patients are currently registered in this clinic category.',
                  actionText: 'Register New Patient',
                  onAction: () => Navigator.of(context).pushNamed(RouteNames.registerPatient),
                )
              else if (isDesktop)
                _buildDesktopTable(context, state.filteredPatients)
              else
                _buildMobileCardList(context, state.filteredPatients),
              const SizedBox(height: 80), // Padding for FAB
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, PatientState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Clinical Directory',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Comprehensive electronic health records, AI dental vision scans, and appointments.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        if (isDesktop)
          ElevatedButton.icon(
            onPressed: () async {
              final bloc = context.read<PatientBloc>();
              final result = await Navigator.of(context).pushNamed(RouteNames.registerPatient);
              if (result == true) {
                bloc.add(const LoadPatientsRequested());
              }
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Register Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsRow(PatientState state) {
    final stats = state.statistics ?? {};
    final total = stats['totalPatients'] ?? state.patients.length;
    final active = stats['activePatients'] ?? state.patients.where((p) => p.status == PatientStatus.active).length;
    final highRisk = stats['highRiskPatients'] ?? state.patients.where((p) => p.riskLevel == PatientRiskLevel.high).length;
    final insured = stats['insuredPatients'] ?? state.patients.where((p) => p.isInsuranceActive).length;

    final metrics = [
      {
        'title': 'Total Patients',
        'value': '$total',
        'icon': Icons.people_alt_rounded,
        'color': AppColors.primary,
        'bg': AppColors.primaryContainer,
      },
      {
        'title': 'Active In-Treatment',
        'value': '$active',
        'icon': Icons.health_and_safety_rounded,
        'color': AppColors.success,
        'bg': AppColors.successContainer,
      },
      {
        'title': 'High Risk / Alerts',
        'value': '$highRisk',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.error,
        'bg': AppColors.errorContainer,
      },
      {
        'title': 'Insured Cases',
        'value': '$insured',
        'icon': Icons.verified_user_rounded,
        'color': AppColors.info,
        'bg': AppColors.infoContainer,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: constraints.maxWidth > 900 ? 2.4 : 2.0,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final m = metrics[index];
            final color = m['color'] as Color;
            final bg = m['bg'] as Color;

            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(m['icon'] as IconData, color: color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m['value'] as String,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          m['title'] as String,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterAndSearchControls(BuildContext context, PatientState state) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Search by patient name, ID (e.g. PT-2026-0042), phone, or attending dentist...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<PatientBloc>().add(const SearchQueryChanged(''));
                          },
                        )
                      : null,
                  onChanged: (val) {
                    context.read<PatientBloc>().add(SearchQueryChanged(val));
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Sort', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                onSelected: (val) {
                  context.read<PatientBloc>().add(SortOrderChanged(val));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'recent', child: Text('Recently Registered')),
                  const PopupMenuItem(value: 'name', child: Text('Patient Name (A-Z)')),
                  const PopupMenuItem(value: 'risk', child: Text('Highest Clinical Risk')),
                  const PopupMenuItem(value: 'age', child: Text('Age (Oldest First)')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'All Patients (${state.patients.length})',
                  isSelected: state.statusFilter == null && state.riskFilter == null,
                  onTap: () {
                    context.read<PatientBloc>().add(const StatusFilterChanged(null));
                    context.read<PatientBloc>().add(const RiskFilterChanged(null));
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip(
                  context,
                  label: 'Active Cases',
                  isSelected: state.statusFilter == PatientStatus.active,
                  onTap: () {
                    context.read<PatientBloc>().add(
                          StatusFilterChanged(
                            state.statusFilter == PatientStatus.active ? null : PatientStatus.active,
                          ),
                        );
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip(
                  context,
                  label: 'High Risk Alerts',
                  color: AppColors.error,
                  isSelected: state.riskFilter == PatientRiskLevel.high,
                  onTap: () {
                    context.read<PatientBloc>().add(
                          RiskFilterChanged(
                            state.riskFilter == PatientRiskLevel.high ? null : PatientRiskLevel.high,
                          ),
                        );
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip(
                  context,
                  label: 'Moderate Risk',
                  color: AppColors.warning,
                  isSelected: state.riskFilter == PatientRiskLevel.medium,
                  onTap: () {
                    context.read<PatientBloc>().add(
                          RiskFilterChanged(
                            state.riskFilter == PatientRiskLevel.medium ? null : PatientRiskLevel.medium,
                          ),
                        );
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip(
                  context,
                  label: 'Inactive',
                  isSelected: state.statusFilter == PatientStatus.inactive,
                  onTap: () {
                    context.read<PatientBloc>().add(
                          StatusFilterChanged(
                            state.statusFilter == PatientStatus.inactive ? null : PatientStatus.inactive,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: activeColor.withAlpha(30),
      checkmarkColor: activeColor,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? activeColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? activeColor : AppColors.border,
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<PatientModel> patients) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 44),
                Expanded(flex: 3, child: Text('PATIENT INFO', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('DEMOGRAPHICS', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('CLINICAL RISK', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('INSURANCE', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('ASSIGNED DENTIST', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('LAST VISIT', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(width: 130, child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final patient = patients[index];

              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RouteNames.patientDetails,
                    arguments: patient,
                  );
                },
                hoverColor: AppColors.surfaceVariant.withAlpha(50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          patient.initials,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  patient.patientNumber,
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                                if (patient.allergies.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${patient.age} yrs • ${patient.gender.displayName}\n${patient.bloodGroup}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: StatusBadge(
                            label: patient.riskLevel.displayName.toUpperCase(),
                            variant: patient.riskLevel == PatientRiskLevel.high
                                ? StatusBadgeVariant.error
                                : (patient.riskLevel == PatientRiskLevel.medium
                                    ? StatusBadgeVariant.warning
                                    : StatusBadgeVariant.success),
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: patient.isInsuranceActive
                            ? Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 16),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      patient.insuranceProvider ?? 'Insured',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Text('Self-Pay / None', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          patient.assignedDentistName ?? 'Unassigned',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          patient.lastVisitDate != null ? dateFormat.format(patient.lastVisitDate!) : 'No visits',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.note_add_outlined, size: 18),
                              color: AppColors.primary,
                              tooltip: 'Quick Clinical Note',
                              onPressed: () => _openAddNoteDialog(context, patient),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  RouteNames.patientDetails,
                                  arguments: patient,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
                              ),
                              child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, List<PatientModel> patients) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final patient = patients[index];
        return PatientSummaryCard(
          patient: patient,
          onTap: () {
            Navigator.of(context).pushNamed(
              RouteNames.patientDetails,
              arguments: patient,
            );
          },
          onAddNote: () => _openAddNoteDialog(context, patient),
        );
      },
    );
  }
}
