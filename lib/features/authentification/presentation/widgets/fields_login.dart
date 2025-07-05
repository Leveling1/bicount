import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FieldsLogin extends StatefulWidget {
  const FieldsLogin({super.key, required this.loading});
  final bool loading;
  @override
  State<FieldsLogin> createState() => _FieldsLoginState();
}

class _FieldsLoginState extends State<FieldsLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthentificationBloc>().add(
        SignInEvent(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            label: "example@gmail.com",
            textController: _emailController,
            title: "Email address",
            type: CustomTextFieldType.email,
            node: _emailFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
          CustomTextField(
            label: "password",
            textController: _passwordController,
            type: CustomTextFieldType.password,
            title: "Password",
            node: _passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          CustomButton(
            text: "Log in",
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
