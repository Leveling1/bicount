import 'package:flutter/material.dart';

import 'custom_form_date_field.dart';

class CustomFormTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomFormTextField({
    super.key,
    this.onChanged,
    required this.hintText,
    this.inputType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      textAlign: TextAlign.start,
      keyboardType: widget.inputType,
      textInputAction: TextInputAction.next,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
      )
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}

class CustomFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final validator;
  final bool isDate;
  const CustomFormField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    this.inputType = TextInputType.text,
    this.validator,
    this.isDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        isDate
        ? CustomFormDateField(
          hintText: hint,
          validator: validator,
          controller: controller,
        )
        : CustomFormTextField(
          controller: controller,
          hintText: hint,
          inputType: inputType,
          validator: validator,
        ),
      ],
    );
  }
}

