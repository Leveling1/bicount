import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:flutter/material.dart';

/// Keeps wallet-specific validation around the shared form field.
class WalletFormField extends StatelessWidget {
  const WalletFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.hint = '',
    this.inputType = TextInputType.text,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<String>(
      validator: (_) => validator(controller.text),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFormField(
            label: label,
            hint: hint,
            controller: controller,
            inputType: inputType,
            enableValidator: false,
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
              child: Text(
                state.errorText!,
                style:
                    theme.inputDecorationTheme.errorStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
