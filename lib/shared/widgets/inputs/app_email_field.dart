import 'package:flutter/material.dart';
import '../../../core/validators/app_validators.dart';
import 'app_text_field.dart';

class AppEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const AppEmailField({
    super.key,
    this.controller,
    this.label = 'Email Address',
    this.hint = 'doctor@dentalclinic.com',
    this.onChanged,
    this.onSubmitted,
    this.customValidator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.email_outlined, size: 20),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: customValidator ?? AppValidators.email,
    );
  }
}
