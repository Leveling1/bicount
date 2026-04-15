import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAmountField extends StatelessWidget {
  const CustomAmountField({
    super.key,
    required this.amount,
    required this.currency,
    this.enableValidator = true,
  });

  final TextEditingController amount;
  final TextEditingController currency;
  final bool? enableValidator;

  String? validator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationFieldRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: -25,
            child: Center(
              child: AmountNumber(
                amount: amount,
                enableValidator: enableValidator,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: CurrencyField(controller: currency),
          ),
        ],
      ),
    );
  }
}

class AmountNumber extends StatefulWidget {
  const AmountNumber({
    super.key,
    required this.amount,
    this.enableValidator = true,
  });

  final TextEditingController amount;
  final bool? enableValidator;

  @override
  State<AmountNumber> createState() => _AmountNumberState();
}

class _AmountNumberState extends State<AmountNumber> {
  final TextEditingController _displayController = TextEditingController();
  final _formatter = const CurrencyAmountFormatter();
  bool _isSyncingDisplay = false;
  bool _isSyncingExternal = false;

  @override
  void initState() {
    super.initState();
    _syncDisplayFromExternal();
    widget.amount.addListener(_syncDisplayFromExternal);
    _displayController.addListener(_syncExternalFromDisplay);
  }

  @override
  void didUpdateWidget(covariant AmountNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount == widget.amount) {
      return;
    }
    oldWidget.amount.removeListener(_syncDisplayFromExternal);
    widget.amount.addListener(_syncDisplayFromExternal);
    _syncDisplayFromExternal();
  }

  @override
  void dispose() {
    widget.amount.removeListener(_syncDisplayFromExternal);
    _displayController.removeListener(_syncExternalFromDisplay);
    _displayController.dispose();
    super.dispose();
  }

  void _syncDisplayFromExternal() {
    if (_isSyncingExternal) {
      return;
    }

    final compact = _compactValue(widget.amount.text);
    final formatted = _formatter.formatText(compact);
    if (_displayController.text == formatted) {
      return;
    }

    _isSyncingDisplay = true;
    _displayController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isSyncingDisplay = false;
  }

  void _syncExternalFromDisplay() {
    if (_isSyncingDisplay) {
      return;
    }

    final compact = _compactValue(_displayController.text);
    if (widget.amount.text == compact) {
      return;
    }

    _isSyncingExternal = true;
    widget.amount.value = TextEditingValue(
      text: compact,
      selection: TextSelection.collapsed(offset: compact.length),
    );
    _isSyncingExternal = false;
  }

  String _compactValue(String value) {
    return value.replaceAll(' ', '').replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return AutoSizeTextField(
      controller: _displayController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      inputFormatters: const [CurrencyAmountFormatter()],
      style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.w500),
      minFontSize: 24.0,
      stepGranularity: 0.5,
      maxLines: 1,
      expands: false,
      decoration: InputDecoration(
        hintText: '0,00',
        hintStyle: TextStyle(
          fontSize: 42.sp,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isCollapsed: true,
      ),
    );
  }
}

class CurrencyAmountFormatter extends TextInputFormatter {
  const CurrencyAmountFormatter();

  String formatText(String rawValue) {
    if (rawValue.isEmpty) {
      return '';
    }
    return _formatWithGrouping(rawValue);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final normalized = newValue.text.replaceAll('.', ',');
    final compactValue = normalized.replaceAll(' ', '');
    final isValid = RegExp(r'^\d*(,\d{0,2})?$').hasMatch(compactValue);
    if (!isValid) {
      return oldValue;
    }

    final rawCursorOffset = normalized
        .substring(0, newValue.selection.baseOffset.clamp(0, normalized.length))
        .replaceAll(' ', '')
        .length;
    final formatted = formatText(compactValue);
    final selectionOffset = _selectionOffsetFromRawCursor(
      formatted,
      rawCursorOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  String _formatWithGrouping(String rawValue) {
    final parts = rawValue.split(',');
    final integerPart = parts.first;
    final decimalPart = parts.length > 1 ? parts[1] : null;

    final groupedInteger = _groupInteger(integerPart);
    if (decimalPart == null) {
      return groupedInteger;
    }

    return '$groupedInteger,$decimalPart';
  }

  String _groupInteger(String integerPart) {
    if (integerPart.length <= 3) {
      return integerPart;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      buffer.write(integerPart[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  int _selectionOffsetFromRawCursor(String formatted, int rawCursorOffset) {
    if (rawCursorOffset <= 0) {
      return 0;
    }

    int seenRawChars = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (formatted[i] != ' ') {
        seenRawChars++;
      }
      if (seenRawChars >= rawCursorOffset) {
        return i + 1;
      }
    }

    return formatted.length;
  }
}

class CurrencyField extends StatelessWidget {
  const CurrencyField({super.key, this.color, required this.controller});

  final TextEditingController controller;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        final currencies = state.config.sortedCurrencies;
        final isEnabled = currencies.isNotEmpty;

        final fallbackCode = state.config.referenceCurrencyCode;
        final selectedCode = _resolveSelectedCode(currencies, fallbackCode);
        _deferControllerSync(selectedCode);

        return _CurrencyChipShell(
          child: DropdownMenuFormField<String>(
            enabled: isEnabled,
            controller: controller,
            initialSelection: currencies.any((c) => c.code == selectedCode)
                ? selectedCode
                : fallbackCode,
            hintText: context.l10n.fieldSelectCurrency,
            textStyle: TextStyle(
              fontSize: AppDimens.textSizeSmall.sp,
              fontWeight: FontWeight.w600,
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: color ?? Theme.of(context).scaffoldBackgroundColor,
              filled: true,
              isCollapsed: true,
              constraints: const BoxConstraints(minHeight: 0, maxHeight: 40),
            ),
            dropdownMenuEntries: currencies
                .map(
                  (currency) => DropdownMenuEntry<String>(
                    value: currency.code,
                    label: currency.code,
                  ),
                )
                .toList(growable: false),
            onSelected: (value) {
              controller.text = value ?? fallbackCode;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.fieldSelectCurrency;
              }
              return null;
            },
          ),
        );
      },
    );
  }

  String _resolveSelectedCode(
    List<AppCurrencyEntity> currencies,
    String fallbackCode,
  ) {
    final rawValue = controller.text.trim().toUpperCase();
    final exists = currencies.any((item) => item.code == rawValue);
    if (exists) {
      return rawValue;
    }
    return fallbackCode;
  }

  void _deferControllerSync(String value) {
    if (controller.text.trim().toUpperCase() == value) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.text.trim().toUpperCase() != value) {
        controller.text = value;
      }
    });
  }
}

class _CurrencyChipShell extends StatelessWidget {
  const _CurrencyChipShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95.sp,
      child: Center(child: child),
    );
  }
}
