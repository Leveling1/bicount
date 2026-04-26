import 'package:bicount/core/localization/l10n_extensions.dart';
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
  final FormFieldValidator<String>? validator;

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
    this.validator,
  });

  @override
  State<CustomSuggestionTextField> createState() =>
      _CustomSuggestionTextFieldState();
}

class _CustomSuggestionTextFieldState extends State<CustomSuggestionTextField> {
  late final TextEditingController _fallbackController;
  TextEditingController? _autocompleteController;
  String? _selectedOption;

  TextEditingController get _effectiveController =>
      widget.controller ?? _fallbackController;

  @override
  void initState() {
    super.initState();
    _fallbackController = TextEditingController(text: widget.controller?.text);
    widget.controller?.addListener(_handleExternalControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CustomSuggestionTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller?.removeListener(_handleExternalControllerChanged);
    if (widget.controller == null && oldWidget.controller != null) {
      _fallbackController.value = oldWidget.controller!.value;
    }
    widget.controller?.addListener(_handleExternalControllerChanged);
    if (_autocompleteController != null &&
        _autocompleteController!.text != _effectiveController.text) {
      _autocompleteController!.value = _effectiveController.value;
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();

  void _attachAutocompleteController(TextEditingController controller) {
    if (identical(_autocompleteController, controller)) {
      return;
    }

    _autocompleteController?.removeListener(
      _handleAutocompleteControllerChanged,
    );
    _autocompleteController = controller;
    _autocompleteController!.addListener(_handleAutocompleteControllerChanged);

    if (_autocompleteController!.text != _effectiveController.text) {
      _autocompleteController!.value = _effectiveController.value;
    }
  }

  void _handleAutocompleteControllerChanged() {
    final controller = _autocompleteController;
    if (controller == null) {
      return;
    }

    final text = controller.text;
    if (_effectiveController.text != text) {
      _effectiveController.value = controller.value;
    }

    final shouldClearSelection =
        _selectedOption != null &&
        _normalize(text) != _normalize(_selectedOption!);

    widget.onChanged?.call(text);
    if (!mounted) {
      return;
    }

    setState(() {
      if (shouldClearSelection) {
        _selectedOption = null;
      }
    });
  }

  void _handleExternalControllerChanged() {
    final controller = widget.controller;
    if (controller == null) {
      return;
    }

    if (_autocompleteController != null &&
        _autocompleteController!.text != controller.text) {
      _autocompleteController!.value = controller.value;
    }

    final shouldClearSelection =
        _selectedOption != null &&
        _normalize(controller.text) != _normalize(_selectedOption!);

    if (!mounted) {
      return;
    }

    setState(() {
      if (shouldClearSelection) {
        _selectedOption = null;
      }
    });
  }

  void _handleSelected(String option) {
    _effectiveController.value = TextEditingValue(
      text: option,
      selection: TextSelection.collapsed(offset: option.length),
    );
    setState(() {
      _selectedOption = option;
    });
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationFieldRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _effectiveController.text),
      onSelected: _handleSelected,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = _normalize(textEditingValue.text);
        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }
        if (_selectedOption != null && query == _normalize(_selectedOption!)) {
          return const Iterable<String>.empty();
        }
        return widget.options.where((String option) {
          return _normalize(option).contains(query);
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
            _attachAutocompleteController(textEditingController);
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) => onFieldSubmitted(),
              textAlign: TextAlign.start,
              keyboardType: widget.inputType,
              textInputAction: TextInputAction.next,
              validator: widget.enableValidator!
                  ? (widget.validator ?? _validator)
                  : null,
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
    widget.controller?.removeListener(_handleExternalControllerChanged);
    _autocompleteController?.removeListener(
      _handleAutocompleteControllerChanged,
    );
    _fallbackController.dispose();
    super.dispose();
  }
}
