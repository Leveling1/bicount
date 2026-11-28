import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String? hintText;

  const CustomSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.autofocus = false,
    this.hintText,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  void _clearText() {
    widget.controller?.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(widget.controller!.text);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.dp50,
      child: BicountPressable.control(
        child: TextFormField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: widget.hintText ?? "Search",
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: AppColors.inactiveColorDark,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color,
            ),
            suffixIcon: widget.controller!.text.isNotEmpty
                ? BicountPressable.button(
                    builder: (statesController) => IconButton(
                      statesController: statesController,
                      icon: const Icon(Icons.clear),
                      onPressed: _clearText,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }
}
