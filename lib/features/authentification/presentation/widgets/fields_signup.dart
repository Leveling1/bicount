import 'package:bicount/core/constants/path.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_border_button.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class FieldsSignUp extends StatefulWidget {
  const FieldsSignUp({super.key});

  @override
  State<FieldsSignUp> createState() => _FieldsSignUpState();
}

class _FieldsSignUpState extends State<FieldsSignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppDimens.spacingMedium,
      children: [
        CustomTextField(
          label: "example@gmail.com",
          textController: _emailController,
          title: "Your email address",
        ),
        CustomTextField(
          label: "min. 8 characters",
          textController: _passwordController,
          password: true,
          title: "Password",
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
        CustomButton(text: "sign up", onPressed: () {}),
        Text("OR"),
        CustomBorderButton(
          text: "Sign up with Google",
          logoPath: AssetPaths.google_logo,
          onPressed: () {},
        ),
      ],
    );
  }
}
