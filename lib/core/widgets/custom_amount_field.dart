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
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          showCurrencyPicker(
            context: context,
            showFlag: true,
            showCurrencyName: true,
            showCurrencyCode: true,
            onSelect: (Currency currency) {
              controller.text = currency.name;
            },
          );
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hintText: hintText,
              hintStyle: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              suffixIcon: SvgPicture.asset(
                'assets/icons/up_and_down.svg',
                width: 15.w,
                height: 15.w,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 20.w,
                minHeight: 20.h,
                maxWidth: 24.w,
                maxHeight: 24.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
