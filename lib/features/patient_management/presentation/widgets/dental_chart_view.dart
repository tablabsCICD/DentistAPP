import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/patient_model.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class DentalChartView extends StatefulWidget {
  final List<ToothRecord> teethRecords;
  final Function(int toothNumber, ToothRecord? record)? onToothSelected;

  const DentalChartView({
    super.key,
    required this.teethRecords,
    this.onToothSelected,
  });

  @override
  State<DentalChartView> createState() => _DentalChartViewState();
}

class _DentalChartViewState extends State<DentalChartView> {
  int? _selectedTooth;

  // Standard Universal / ISO FDI numbering
  // Upper arch: 18..11 (Upper Right) & 21..28 (Upper Left)
  final List<int> _upperArchRight = [18, 17, 16, 15, 14, 13, 12, 11];
  final List<int> _upperArchLeft = [21, 22, 23, 24, 25, 26, 27, 28];

  // Lower arch: 48..41 (Lower Right) & 31..38 (Lower Left)
  final List<int> _lowerArchRight = [48, 47, 46, 45, 44, 43, 42, 41];
  final List<int> _lowerArchLeft = [31, 32, 33, 34, 35, 36, 37, 38];

  ToothRecord? _getRecordForTooth(int toothNumber) {
    try {
      return widget.teethRecords.firstWhere((r) => r.toothNumber == toothNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecord = _selectedTooth != null ? _getRecordForTooth(_selectedTooth!) : null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Dental Odontogram (FDI Chart)',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap any tooth for clinical diagnostic records & restoration history',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              _buildChartLegendSummary(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Upper Arch
          Center(
            child: Text(
              'UPPER MAXILLARY ARCH',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._upperArchRight.map((t) => _buildToothButton(t)),
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border,
                ),
                ..._upperArchLeft.map((t) => _buildToothButton(t)),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Lower Arch
          Center(
            child: Text(
              'LOWER MANDIBULAR ARCH',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._lowerArchRight.map((t) => _buildToothButton(t)),
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border,
                ),
                ..._lowerArchLeft.map((t) => _buildToothButton(t)),
              ],
            ),
          ),

          // Selected Tooth Details Box
          if (_selectedTooth != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withAlpha(120),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: selectedRecord?.condition.badgeColor.withAlpha(40) ?? AppColors.successContainer,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: selectedRecord?.condition.badgeColor ?? AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tooth #$_selectedTooth',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: selectedRecord?.condition.badgeColor.withAlpha(30) ?? AppColors.successContainer,
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Text(
                                selectedRecord?.condition.displayName ?? 'Healthy Tooth Structure',
                                style: AppTypography.labelSmall.copyWith(
                                  color: selectedRecord?.condition.badgeColor ?? AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedRecord?.notes ?? 'No recorded caries, restorations or pathologies.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        if (selectedRecord?.surface != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Affected Surface: ${selectedRecord!.surface}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _selectedTooth = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToothButton(int toothNumber) {
    final record = _getRecordForTooth(toothNumber);
    final condition = record?.condition ?? ToothCondition.healthy;
    final isSelected = _selectedTooth == toothNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Tooltip(
        message: 'Tooth #$toothNumber - ${condition.displayName}',
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTooth = toothNumber;
            });
            widget.onToothSelected?.call(toothNumber, record);
          },
          borderRadius: AppSpacing.borderRadiusSm,
          child: Container(
            width: 36,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : AppColors.surface,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : condition == ToothCondition.healthy
                        ? AppColors.border
                        : condition.badgeColor,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: condition.badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$toothNumber',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartLegendSummary() {
    final legends = [
      {'label': 'Healthy', 'color': AppColors.success},
      {'label': 'Caries', 'color': AppColors.error},
      {'label': 'Restored', 'color': AppColors.info},
      {'label': 'RCT', 'color': const Color(0xFFEC4899)},
      {'label': 'Crown/Implant', 'color': const Color(0xFF8B5CF6)},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 4,
      children: legends.map((l) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: l['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l['label'] as String,
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }
}
