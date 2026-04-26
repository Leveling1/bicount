import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    if (_selectedDate != null) {
      if (_controller.text.trim().isEmpty) {
        _controller.text = formatedDateTimeNumericFullYear(_selectedDate!);
      }
    }
    _controller.addListener(_syncSelectedDateFromController);
  }

  DateTime? _resolveControllerDate() {
    final rawValue = widget.controller?.text.trim() ?? '';
    if (rawValue.isEmpty) {
      return null;
    }
    return parseFormDate(rawValue);
  }

  void _syncSelectedDateFromController() {
    final parsedDate = parseFormDate(_controller.text);
    final previousDate = _selectedDate;
    _selectedDate = parsedDate;

    if (parsedDate != null && !_isSameDate(previousDate, parsedDate)) {
      widget.onChanged?.call(parsedDate);
    }
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return left == right;
    }

    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
        _controller.text = formatedDateTimeNumericFullYear(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
        _DateSlashInputFormatter(),
      ],
      validator: (value) => widget.validator?.call(_selectedDate),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          onPressed: _pickDate,
          icon: const Icon(
            Icons.calendar_today,
            color: AppColors.inactiveColorDark,
          ),
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

class _DateSlashInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmedDigits = digits.length > 8 ? digits.substring(0, 8) : digits;
    final isDeleting = newValue.text.length < oldValue.text.length;
    final formatted = _formatDigits(trimmedDigits, isDeleting: isDeleting);
    final digitsBeforeCursor = _countDigitsBeforeCursor(newValue);
    final cursorOffset = _resolveCursorOffset(
      digitsBeforeCursor,
      isDeleting: isDeleting,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _formatDigits(String digits, {required bool isDeleting}) {
    if (digits.length <= 2) {
      if (digits.length == 2 && !isDeleting) {
        return '$digits/';
      }
      return digits;
    }

    final day = digits.substring(0, 2);
    final month = digits.substring(2, digits.length > 4 ? 4 : digits.length);

    if (digits.length <= 4) {
      final buffer = StringBuffer('$day/$month');
      if (digits.length == 4 && !isDeleting) {
        buffer.write('/');
      }
      return buffer.toString();
    }

    final year = digits.substring(4);
    return '$day/$month/$year';
  }

  int _countDigitsBeforeCursor(TextEditingValue value) {
    final rawOffset = value.selection.baseOffset;
    if (rawOffset <= 0) {
      return 0;
    }

    final safeOffset = rawOffset > value.text.length
        ? value.text.length
        : rawOffset;
    return value.text
        .substring(0, safeOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;
  }

  int _resolveCursorOffset(int digitCount, {required bool isDeleting}) {
    final safeDigitCount = digitCount < 0
        ? 0
        : digitCount > 8
        ? 8
        : digitCount;

    return _formatDigits('0' * safeDigitCount, isDeleting: isDeleting).length;
  }
}
