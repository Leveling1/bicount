import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
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
          Expanded(flex: 1, child: CurrencyField(controller: currency)),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: CustomFormTextField(
              hintText: context.l10n.fieldEnterAmount,
              inputType: TextInputType.number,
              validator: enableValidator!
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
  CurrencyField({
    super.key,
    required this.controller,
    this.defaultCurrencyCode = 'USD',
  }) {
    if (controller.text.isEmpty) {
      controller.text = defaultCurrencyCode;
    }
  }

  final TextEditingController controller;
  final String defaultCurrencyCode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enableInteractiveSelection: false,
      decoration: InputDecoration(hintText: context.l10n.fieldSelectCurrency),
      style: TextStyle(
        fontSize: AppDimens.textSizeMedium.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
