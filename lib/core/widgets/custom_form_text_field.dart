import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class CustomFormTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextInputType? inputType;
  final TextEditingController? controller;

  const CustomFormTextField({
    super.key,
    this.onChanged,
    required this.hintText,
    this.inputType = TextInputType.text,
    this.controller,
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
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: _controller,
        textAlign: TextAlign.start,
        keyboardType: widget.inputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          hintText: widget.hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(color: AppColors.inactiveColorDark),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
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
