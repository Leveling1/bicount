import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../utils/date_format_utils.dart';
import '../utils/form_date_utils.dart';

class CustomFormDateField extends StatefulWidget {
  final ValueChanged<DateTime>? onChanged;
  final String hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final TextEditingController? controller;
  final String? Function(DateTime?)? validator;

  const CustomFormDateField({
    super.key,
    this.onChanged,
    required this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.controller,
  });

  @override
  State<CustomFormDateField> createState() => _CustomFormDateFieldState();
}

class _CustomFormDateFieldState extends State<CustomFormDateField> {
  late final TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _selectedDate = widget.initialDate ?? _resolveControllerDate();
    _controller.addListener(_syncSelectedDateFromController);
    if (_selectedDate != null) {
      if (_controller.text.trim().isEmpty) {
        _controller.text = formatDate(_selectedDate!);
      }
    }
  }

  DateTime? _resolveControllerDate() {
    final rawValue = widget.controller?.text.trim() ?? '';
    if (rawValue.isEmpty) {
      return null;
    }
    return parseFormDate(rawValue);
  }

  void _syncSelectedDateFromController() {
    _selectedDate = parseFormDate(_controller.text);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = formatedDateTimeNumeric(picked);
      });
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Empêche la saisie manuelle
      onTap: _pickDate,
      validator: (value) => widget.validator?.call(_selectedDate),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: AppColors.inactiveColorDark,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // On ne dispose que si le controller n’a pas été passé de l’extérieur
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
