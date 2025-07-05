import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

enum CustomTextFieldType { password, email, name, postname }

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.textController,
    required this.title,
    this.type = CustomTextFieldType.name,
    this.node,
    this.textInputAction,
    this.onFieldSubmitted,
  });
  final String label;
  final TextEditingController textController;
  final String title;
  final FocusNode? node;
  final CustomTextFieldType type;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.type == CustomTextFieldType.password;
  }

  String? _validator(String? value) {
    switch (widget.type) {
      case CustomTextFieldType.email:
        if (value == null || value.isEmpty) return 'Email required';
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailRegex.hasMatch(value)) return 'Invalid email';
        break;
      case CustomTextFieldType.password:
        if (value == null || value.isEmpty) return 'Password required';
        if (value.length < 8) return 'At least 8 characters';
        break;
      case CustomTextFieldType.name:
      case CustomTextFieldType.postname:
        if (value == null || value.isEmpty) return 'This field is required';
        if (value.length < 2) return 'Too short';
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.spacingSmall,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
        TextFormField(
          controller: widget.textController,
          obscureText: _obscure,
          focusNode: widget.node,
          validator: _validator,
          keyboardType: widget.type == CustomTextFieldType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            hint: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.inactiveColorDark,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.inactiveColorDark),
            ),
            suffixIcon: widget.type == CustomTextFieldType.password
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.inactiveColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
