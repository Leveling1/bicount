import 'package:bicount/core/constants/path.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_border_button.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _rememberMe = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthentificationBloc>().add(
        SignUpEvent(
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
            title: "Your email address",
            type: CustomTextFieldType.email,
            node: _emailFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
          CustomTextField(
            label: "min. 8 characters",
            textController: _passwordController,
            type: CustomTextFieldType.password,
            title: "Password",
            node: _passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("I agree with therms of use"),
              Checkbox(
                value: _rememberMe,
                activeColor: Theme.of(context).colorScheme.surface,
                onChanged: (bool? newValue) {
                  setState(() {
                    _rememberMe = newValue ?? false;
                  });
                },
              ),
            ],
          ),
          CustomButton(
            text: "sign up",
            loading: widget.loading,
            onPressed: _submit,
          ),
          Text("OR"),
          CustomBorderButton(
            text: "Sign up with Google",
            logoPath: AssetPaths.google_logo,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
