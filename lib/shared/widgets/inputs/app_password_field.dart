import 'package:flutter/material.dart';
import '../../../core/validators/app_validators.dart';
import 'app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final bool showRequirementsHelper;

  const AppPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = '••••••••••••',
    this.onChanged,
    this.onSubmitted,
    this.customValidator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.showRequirementsHelper = false,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          obscureText: _obscureText,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            tooltip: _obscureText ? 'Show password' : 'Hide password',
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          validator: widget.customValidator ?? AppValidators.password,
        ),
      ],
    );
  }
}
