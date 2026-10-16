import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../cards/app_card.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final double cardMaxWidth;

  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.footer,
    this.cardMaxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final horizontalPadding = constraints.maxWidth < 600 ? AppSpacing.md : AppSpacing.xl;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: _buildBrandHero(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxl),
                          Flexible(
                            flex: 1,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: cardMaxWidth),
                              child: _buildCardContent(isWide: true),
                            ),
                          ),
                        ],
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: _buildCardContent(isWide: false),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardContent({required bool isWide}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isWide) ...[
          _buildMobileHeader(),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppCard(
          padding: AppSpacing.paddingXl,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.displayLarge.copyWith(fontSize: 24)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: AppTypography.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.xl),
              child,
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.lg),
          footer!,
        ],
      ],
    );
  }

  Widget _buildBrandHero() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'DentFlow AI',
            style: AppTypography.displayLarge.copyWith(color: AppColors.primary, fontSize: 36),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The complete AI-assisted dental SaaS platform designed for modern dental clinics, clinicians, and administrative teams.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildHeroFeatureItem(Icons.auto_awesome_rounded, 'AI-driven diagnostic assistance & imaging workflow'),
          const SizedBox(height: AppSpacing.sm),
          _buildHeroFeatureItem(Icons.shield_outlined, 'Role-aware clinical access and automated security'),
          const SizedBox(height: AppSpacing.sm),
          _buildHeroFeatureItem(Icons.sync_rounded, 'Multi-location synchronization and subscription management'),
        ],
      ),
    );
  }

  Widget _buildHeroFeatureItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'DentFlow AI',
          style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
