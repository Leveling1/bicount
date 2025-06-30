import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.textController,
    required this.title,
    this.node,
  });
  final String label;
  final TextEditingController textController;
  final String title;
  final FocusNode? node;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.spacingSmall,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
        TextFormField(
          controller: widget.textController,
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
          ),
        ),
      ],
    );
  }
}
