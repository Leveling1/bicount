import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/notification_helper.dart';
import 'package:bicount/features/authentification/presentation/widgets/fields_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/authentification_bloc.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: BlocConsumer<AuthentificationBloc, AuthentificationState>(
        listener: (context, state) {
          if (state is SignUpFailure) {
            NotificationHelper.showFailureNotification(context, state.error);
          } else if (state is SignUpSuccess) {
            GoRouter.of(context).go('/');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: AppDimens.paddingAllMedium,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: height - 2 * AppDimens.paddingAllMedium.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's Get Started",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              "Fill the login to continue",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      FieldsSignUp(loading: state is SignUpLoading),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/login');
                            },
                            child: Text(
                              "Log in",
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
            ),
          );
        },
      ),
    );
  }
}
