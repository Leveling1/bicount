import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FieldsSignUp extends StatefulWidget {
  const FieldsSignUp({super.key, required this.loading});

  final bool loading;

  @override
  State<FieldsSignUp> createState() => _FieldsSignUpState();
}

class _FieldsSignUpState extends State<FieldsSignUp> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

  void _submit() {
    if ((_formKey.currentState?.validate() ?? false) && _acceptTerms) {
      context.read<AuthentificationBloc>().add(
        SignUpEvent(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: AppDimens.spacingMedium,
        children: [
          CustomTextField(
            label: 'example',
            textController: _usernameController,
            title: context.l10n.authYourUserName,
            node: _usernameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocus);
            },
          ),
          CustomTextField(
            label: 'example@gmail.com',
            textController: _emailController,
            title: context.l10n.authYourEmailAddress,
            type: CustomTextFieldType.email,
            node: _emailFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
          CustomTextField(
            label: context.l10n.authMinCharactersHint,
            textController: _passwordController,
            type: CustomTextFieldType.password,
            title: context.l10n.authPassword,
            node: _passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.authAgreeTerms,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Checkbox(
                value: _acceptTerms,
                activeColor: Theme.of(context).colorScheme.surface,
                onChanged: (value) {
                  setState(() => _acceptTerms = value ?? false);
                },
              ),
            ],
          ),
          CustomButton(
            text: context.l10n.authSignUp,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
