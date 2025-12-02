import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  final String title;
  final String? hintText;
  final int? initialValue;
  final List<DropdownMenuEntry<int>> menuEntries;
  final ValueChanged<int?>? onChanged;

  const CustomDropdownMenu({
    super.key,
    required this.title,
    this.initialValue,
    required this.menuEntries,
    this.hintText,
    this.onChanged,
  });

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
        SizedBox(height: 8),
        DropdownMenuFormField(
          width: double.infinity,
          hintText: widget.hintText,
          dropdownMenuEntries: widget.menuEntries,
          initialSelection: _selectedValue,
          onSelected: (int? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged?.call(newValue); // Envoie la valeur au parent
          },
          validator: (value) =>
              value == null ? 'Veuillez sélectionner le niveau' : null,
        ),
      ],
    );
  }
}
