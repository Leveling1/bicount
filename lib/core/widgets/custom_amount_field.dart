import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_form_text_field.dart';

class CustomAmountField extends StatelessWidget {
  final TextEditingController amount;
  final TextEditingController currency;
  final bool? enableValidator;

  const CustomAmountField({
    super.key,
    required this.amount,
    required this.currency,
    this.enableValidator = true,
  });

  String? _validator(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
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
              hintText: 'Enter amount',
              inputType: TextInputType.number,
              validator: enableValidator! ? _validator : null,
              controller: amount,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String defaultCurrencyCode;

  CurrencyField({
    super.key,
    required this.controller,
    this.hintText = 'Select currency',
    this.defaultCurrencyCode = 'USD',
  }) {
    if (controller.text.isEmpty) {
      controller.text = defaultCurrencyCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enableInteractiveSelection: false,
      decoration: InputDecoration(hintText: hintText),
      style: TextStyle(
        fontSize: AppDimens.textSizeMedium.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
