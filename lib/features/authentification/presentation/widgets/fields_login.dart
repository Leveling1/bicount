import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class FieldsLogin extends StatefulWidget {
  const FieldsLogin({super.key});

  @override
  State<FieldsLogin> createState() => _FieldsLoginState();
}

class _FieldsLoginState extends State<FieldsLogin> {
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
          title: "Email address",
        ),
        CustomTextField(
          label: "password",
          textController: _passwordController,
          password: true,
          title: "Password",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Remember me next time"),
            Checkbox(
              activeColor: Theme.of(context).colorScheme.surface,
              value: _rememberMe,
              onChanged: (bool? newValue) {
                setState(() {
                  _rememberMe = newValue ?? false;
                });
              },
            ),
          ],
        ),
        CustomButton(
          text: "Log in",
          onPressed: () {
            print("object");
          },
        ),
      ],
    );
  }
}
