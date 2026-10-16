import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../shared/widgets/feedback/app_success_state.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/password_recovery_bloc.dart';
import '../view_model/password_recovery_event.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Password Updated',
      child: AppSuccessState(
        title: 'Success!',
        message: 'Your dental clinic account password has been reset securely. You can now sign in with your new credentials.',
        actionText: 'Continue to Login',
        onAction: () {
          context.read<PasswordRecoveryBloc>().add(ResetFlowReset());
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.login,
            (route) => false,
          );
        },
      ),
    );
  }
}
