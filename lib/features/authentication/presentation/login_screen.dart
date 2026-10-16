import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/auth_bloc.dart';
import '../view_model/auth_event.dart';
import '../view_model/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dentist@clinic.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  UserRole _selectedRole = UserRole.dentist;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
              selectedRole: _selectedRole,
            ),
          );
    }
  }

  void _setDemoCredentials(String email, UserRole role) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'Password123!';
      _selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status.name == 'success' && state.nextRoute != null) {
          Navigator.of(context).pushReplacementNamed(state.nextRoute!);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: 'Sign In to Your Practice',
          subtitle: 'Access clinical records, AI diagnostics, and clinic scheduling.',
          footer: _buildFooter(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Selector Tabs
                _buildRoleSelector(),
                const SizedBox(height: AppSpacing.lg),

                if (state.errorMessage != null) ...[
                  StatusCard(
                    title: 'Authentication Failed',
                    message: state.errorMessage,
                    type: StatusType.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                AppEmailField(
                  controller: _emailController,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: AppSpacing.md),

                AppPasswordField(
                  controller: _passwordController,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: AppSpacing.xs),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  text: 'Sign In as ${_selectedRole.displayName}',
                  isLoading: state.isLoading,
                  icon: Icons.login_rounded,
                  onPressed: _onLoginPressed,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Quick Demo Accounts Selector for Fast Evaluation
                _buildDemoAccountShortcuts(state.isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleTab(
              role: UserRole.dentist,
              label: 'Dentist / Clinician',
              icon: Icons.medical_information_outlined,
            ),
          ),
          Expanded(
            child: _buildRoleTab(
              role: UserRole.staff,
              label: 'Clinic Staff',
              icon: Icons.badge_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          if (role == UserRole.staff && _emailController.text.contains('dentist')) {
            _emailController.text = 'staff@clinic.com';
          } else if (role == UserRole.dentist && _emailController.text.contains('staff')) {
            _emailController.text = 'dentist@clinic.com';
          }
        });
      },
      borderRadius: AppSpacing.borderRadiusSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusSm,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccountShortcuts(bool isLoading) {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(120),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEMO TEST ACCOUNTS (CLICK TO AUTOFILL):',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _buildDemoChip('Dentist (Active)', () => _setDemoCredentials('dentist@clinic.com', UserRole.dentist), isLoading),
              _buildDemoChip('Staff (Active)', () => _setDemoCredentials('staff@clinic.com', UserRole.staff), isLoading),
              _buildDemoChip('New Admin (Setup Incomplete)', () => _setDemoCredentials('newadmin@clinic.com', UserRole.administrator), isLoading),
              _buildDemoChip('Unverified Clinic', () => _setDemoCredentials('unverified@clinic.com', UserRole.administrator), isLoading),
              _buildDemoChip('Blocked Account', () => _setDemoCredentials('blocked@clinic.com', UserRole.dentist), isLoading),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String label, VoidCallback onTap, bool disabled) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: disabled ? null : onTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Don't have an onboarded clinic? ",
          style: AppTypography.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(RouteNames.clinicOnboarding),
          child: Text(
            'Register Clinic',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
