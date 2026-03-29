import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AuthEmailCodeForm extends StatefulWidget {
  const AuthEmailCodeForm({
    super.key,
    required this.onVerify,
    required this.loading,
  });

  final void Function(String code) onVerify;
  final bool loading;

  @override
  State<AuthEmailCodeForm> createState() => _AuthEmailCodeFormState();
}

class _AuthEmailCodeFormState extends State<AuthEmailCodeForm> {
  late final TextEditingController _codeController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: _validateCode,
            decoration: InputDecoration(
              hintText: context.l10n.authCodeFieldHint,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppDimens.spacingExtraSmall),
          Text(
            context.l10n.authCodeHelper,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          CustomButton(
            text: context.l10n.authVerifyCode,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onVerify(_codeController.text.trim());
    }
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return context.l10n.validationFieldRequired;
    }
    if (code.length < 6) {
      return context.l10n.validationTooShort;
    }
    return null;
  }
}
