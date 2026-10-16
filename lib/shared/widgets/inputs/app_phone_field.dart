import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/validators/app_validators.dart';
import 'app_text_field.dart';

class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const AppPhoneField({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.hint = '+91 98765 43210',
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
      keyboardType: TextInputType.phone,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
      ],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: customValidator ?? AppValidators.phone,
    );
  }
}
