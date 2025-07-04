import 'package:bicount/core/constants/path.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:bicount/features/authentification/presentation/widgets/fields_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/authentification_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<AuthentificationBloc, AuthentificationState>(
          builder: (context, state) {
            return Padding(
              padding: AppDimens.paddingAllMedium,
              child: Column(
                children: [
                  Image.asset(AssetPaths.image_login, height: 250),
                  FieldsLogin(),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          GoRouter.of(context).go('/signUp');
                        },
                        child: Text(
                          "Sign up",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
