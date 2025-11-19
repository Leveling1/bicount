import 'package:bicount/core/themes/app_dimens.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_form_text_field.dart';

class CustomAmountField extends StatelessWidget {
  final TextEditingController amount;
  final TextEditingController currency;

  const CustomAmountField({
    super.key,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 1, child: CurrencyField(controller: currency)),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: CustomFormTextField(
            hintText: 'Enter amount',
            inputType: TextInputType.number,
            onChanged: (value) => amount.text = value,
          ),
        ),
      ],
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
    return Container(
      height: 49.h,
      alignment: Alignment.center,
      padding: AppDimens.paddingAllSmall.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      child: Text(
        'USD',
        style: TextStyle(
          fontSize: AppDimens.textSizeMedium.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
