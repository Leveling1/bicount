import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  const CustomDropdownMenu({
    super.key,
    required this.title,
    required this.menuEntries,
    this.hintText,
    this.initialValue,
    this.onChanged,
  });

  final String title;
  final String? hintText;
  final int? initialValue;
  final List<DropdownMenuEntry<int>> menuEntries;
  final ValueChanged<int?>? onChanged;

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  late int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownMenuFormField<int>(
          width: double.infinity,
          hintText: widget.hintText,
          dropdownMenuEntries: widget.menuEntries,
          initialSelection: _selectedValue,
          onSelected: (int? newValue) {
            setState(() => _selectedValue = newValue);
            widget.onChanged?.call(newValue);
          },
          validator: (value) =>
              value == null ? context.l10n.validationFieldRequired : null,
        ),
      ],
    );
  }
}
