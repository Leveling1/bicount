import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AuthEmailRequestForm extends StatefulWidget {
  const AuthEmailRequestForm({
    super.key,
    required this.onSubmit,
    required this.loading,
    this.initialEmail,
  });

  final void Function(String email) onSubmit;
  final bool loading;
  final String? initialEmail;

  @override
  State<AuthEmailRequestForm> createState() => _AuthEmailRequestFormState();
}

class _AuthEmailRequestFormState extends State<AuthEmailRequestForm> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _emailController,
            builder: (context, value, _) {
              final hasValidEmail =
                  _hasValidEmail(value.text) && !widget.loading;

              return TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                decoration: InputDecoration(
                  hintText: context.l10n.authEmailPlaceholder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: hasValidEmail
                      ? CustomAuthIconButton(onPressed: _submit)
                      : null,
                ),
                onFieldSubmitted: (_) => _submit(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailController.text.trim());
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return context.l10n.validationEmailRequired;
    }

    if (!_hasValidEmail(email)) {
      return context.l10n.validationInvalidEmail;
    }

    return null;
  }

  bool _hasValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
