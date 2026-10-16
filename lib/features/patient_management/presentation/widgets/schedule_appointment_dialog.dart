import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_dropdown.dart';

class ScheduleAppointmentDialog extends StatefulWidget {
  final String patientName;
  final String? defaultDentist;
  final Function(DateTime date, String timeSlot, String procedure, String dentist) onSchedule;

  const ScheduleAppointmentDialog({
    super.key,
    required this.patientName,
    this.defaultDentist,
    required this.onSchedule,
  });

  @override
  State<ScheduleAppointmentDialog> createState() => _ScheduleAppointmentDialogState();
}

class _ScheduleAppointmentDialogState extends State<ScheduleAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController(text: 'Routine Dental Examination & Prophylaxis');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  String _selectedTimeSlot = '10:00 AM - 10:45 AM';
  late String _selectedDentist;

  final List<String> _timeSlots = [
    '09:00 AM - 09:45 AM',
    '10:00 AM - 10:45 AM',
    '11:15 AM - 12:00 PM',
    '02:00 PM - 02:45 PM',
    '03:00 PM - 03:45 PM',
    '04:30 PM - 05:15 PM',
  ];

  final List<String> _dentists = [
    'Dr. Marcus Vance',
    'Dr. Arjun Patel',
    'Dr. Elena Rostova',
  ];

  final List<String> _procedures = [
    'Routine Dental Examination & Prophylaxis',
    'AI Radiograph Scan & Diagnostic Review',
    'Class II Composite Filling',
    'Endodontic Therapy (Root Canal)',
    'Crown Preparation & Scan',
    'Ultrasonic Scaling & Root Planing',
    'Tooth Extraction / Oral Surgery',
    'Orthodontic Clear Aligner Review',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDentist = widget.defaultDentist ?? _dentists.first;
  }

  @override
  void dispose() {
    _procedureController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSchedule(
        _selectedDate,
        _selectedTimeSlot,
        _procedureController.text.trim(),
        _selectedDentist,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Schedule Visit',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Book a clinical chair appointment for ${widget.patientName}.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date Picker Button
                InkWell(
                  onTap: _pickDate,
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withAlpha(90),
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              dateFormat.format(_selectedDate),
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Text('Change Date', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                AppDropdown<String>(
                  label: 'Time Slot',
                  value: _selectedTimeSlot,
                  items: _timeSlots
                      .map((slot) => DropdownMenuItem(value: slot, child: Text(slot)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTimeSlot = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppDropdown<String>(
                  label: 'Attending Practitioner',
                  value: _selectedDentist,
                  items: _dentists
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDentist = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppDropdown<String>(
                  label: 'Clinical Procedure',
                  value: _procedures.contains(_procedureController.text) ? _procedureController.text : _procedures.first,
                  items: _procedures
                      .map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _procedureController.text = val);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    PrimaryButton(
                      text: 'Confirm Appointment',
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
