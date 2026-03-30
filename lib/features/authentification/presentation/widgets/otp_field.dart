import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/themes/app_dimens.dart';

class OtpField extends StatelessWidget {
  OtpField({super.key, required this.validateCode, required this.submit});

  final TextEditingController codeController = TextEditingController();
  final String? Function(String?) validateCode;
  final void Function() submit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        validator: validateCode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: context.l10n.authCodeFieldHint,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(
              color:
                  Theme.of(context).elevatedButtonTheme.style!.backgroundColor!
                      .resolve({})
                      ?.withValues(alpha: 0.7) ??
                  Colors.grey,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(
              color:
                  Theme.of(context).elevatedButtonTheme.style?.backgroundColor
                      ?.resolve({})
                      ?.withValues(alpha: 0.7) ??
                  Colors.grey,
              width: 1.8,
            ),
          ),
        ),
        onFieldSubmitted: (_) => submit(),
      ),
    );
  }
}
