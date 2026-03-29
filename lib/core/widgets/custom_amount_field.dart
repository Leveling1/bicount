import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_form_text_field.dart';

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

  String? _validator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationFieldRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: CurrencyField(controller: currency)),
          const SizedBox(width: 10),
          Expanded(
            flex: 7,
            child: CustomFormTextField(
              hintText: context.l10n.fieldEnterAmount,
              inputType: TextInputType.number,
              validator: enableValidator == true
                  ? (value) => _validator(context, value)
                  : null,
              controller: amount,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyField extends StatelessWidget {
  const CurrencyField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        final currencies = state.config.sortedCurrencies;
        if (currencies.isEmpty) {
          return TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText: context.l10n.fieldSelectCurrency,
            ),
          );
        }

        final fallbackCode = state.config.referenceCurrencyCode;
        final selectedCode = _resolveSelectedCode(currencies, fallbackCode);
        _deferControllerSync(selectedCode);

        return DropdownMenuFormField<String>(
          controller: controller,
          initialSelection: currencies.any((c) => c.code == selectedCode)
              ? selectedCode
              : fallbackCode,
          hintText: context.l10n.fieldSelectCurrency,
          textStyle: TextStyle(
            fontSize: AppDimens.textSizeMedium.sp,
            fontWeight: FontWeight.w600,
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
