import 'package:bicount/core/constants/path.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/features/authentification/presentation/widgets/fields_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/authentification_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthentificationBloc, AuthentificationState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              NotificationHelper.showFailureNotification(context, state.error);
            } else if (state is SignInSuccess) {
              GoRouter.of(context).go('/');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: AppDimens.paddingAllMedium,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: height - 2 * AppDimens.paddingAllMedium.vertical,
                  child: Column(
                    children: [
                      Image.asset(AssetPaths.image_login, height: 250),
                      FieldsLogin(loading: state is SignInLoading),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
