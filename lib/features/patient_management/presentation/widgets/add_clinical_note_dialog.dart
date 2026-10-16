import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class AddClinicalNoteDialog extends StatefulWidget {
  final String patientName;
  final Function(String title, String content) onSave;

  const AddClinicalNoteDialog({
    super.key,
    required this.patientName,
    required this.onSave,
  });

  @override
  State<AddClinicalNoteDialog> createState() => _AddClinicalNoteDialogState();
}

class _AddClinicalNoteDialogState extends State<AddClinicalNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      widget.onSave(_titleController.text.trim(), _contentController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          child: const Icon(Icons.note_add_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Add Clinical Note',
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
                  'Record treatment observation or diagnostic note for ${widget.patientName}.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _titleController,
                  label: 'Note Subject / Procedure Title',
                  hint: 'e.g. Post-operative evaluation or Restorative assessment',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a note title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _contentController,
                  label: 'Clinical Remarks & Observations',
                  hint: 'Enter detailed clinical findings, anesthesia used, post-op instructions...',
                  maxLines: 5,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter clinical remarks';
                    }
                    return null;
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
                      text: 'Save Clinical Note',
                      isLoading: _isLoading,
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
