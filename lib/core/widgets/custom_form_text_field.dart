import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class CustomFormTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextInputType? inputType;
  const CustomFormTextField({super.key, this.onChanged, required this.hintText, this.inputType = TextInputType.text});

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
      widget.onChanged?.call(_controller.text);
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
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: AppColors.inactiveColorDark,
          ),
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
    _controller.dispose();
    super.dispose();
  }
}
