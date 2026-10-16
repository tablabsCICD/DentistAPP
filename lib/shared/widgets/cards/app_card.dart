import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.elevation,
    this.borderRadius,
    this.customShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppSpacing.borderRadiusMd;

    final cardChild = Container(
      padding: padding ?? AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: borderWidth ?? 1.0,
        ),
        boxShadow: customShadow ??
            (elevation != null && elevation! > 0
                ? [
                    BoxShadow(
                      color: const Color.fromRGBO(15, 23, 42, 0.06),
                      blurRadius: elevation! * 4,
                      offset: Offset(0, elevation!),
                    ),
                  ]
                : AppShadows.soft),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          hoverColor: AppColors.primaryContainer.withValues(alpha: 0.15),
          splashColor: AppColors.primaryContainer.withValues(alpha: 0.3),
          child: cardChild,
        ),
      );
    }

    return cardChild;
  }
}
