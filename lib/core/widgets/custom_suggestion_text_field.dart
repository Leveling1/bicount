import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class CustomSuggestionTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onAdd;
  final String hintText;
  final TextInputType inputType;
  final List<String> options;
  final TextEditingController? controller;
  final bool isVisible;
  final bool? enableValidator;

  const CustomSuggestionTextField({
    super.key,
    required this.hintText,
    this.inputType = TextInputType.text,
    required this.options,
    this.onChanged,
    this.onAdd,
    this.controller,
    this.isVisible = true,
    this.enableValidator = true,
  });

  @override
  State<CustomSuggestionTextField> createState() =>
      _CustomSuggestionTextFieldState();
}

class _CustomSuggestionTextFieldState extends State<CustomSuggestionTextField> {
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

  String? _validator(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return widget.options.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Card(
                elevation: 4.0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(
                        option,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            );
          },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            if (widget.controller != null &&
                widget.controller != textEditingController) {
              textEditingController.text = widget.controller!.text;

              widget.controller!.addListener(() {
                if (textEditingController.text != widget.controller!.text) {
                  textEditingController.text = widget.controller!.text;
                }
              });

              textEditingController.addListener(() {
                if (widget.controller!.text != textEditingController.text) {
                  widget.controller!.text = textEditingController.text;
                }
              });
            }
            return TextFormField(
              controller: widget.controller ?? textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) => onFieldSubmitted(),
              textAlign: TextAlign.start,
              keyboardType: widget.inputType,
              textInputAction: TextInputAction.next,
              validator: widget.enableValidator! ? _validator : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon: widget.isVisible
                    ? IconButton(
                        icon: Icon(
                          Icons.add,
                          color: AppColors.inactiveColorDark,
                        ),
                        onPressed: widget.onAdd,
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
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
