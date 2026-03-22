import 'package:bicount/core/constants/path.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_brand_mark.dart';
import 'package:bicount/features/authentification/presentation/widgets/fields_login.dart';
import 'package:bicount/features/authentification/presentation/widgets/separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/authentification_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthentificationBloc, AuthentificationState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              NotificationHelper.showFailureNotification(
                context,
                localizeRuntimeMessage(context, state.error),
              );
            } else if (state is SignInSuccess) {
              GoRouter.of(context).go('/');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: AppDimens.paddingAllMedium,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*BicountReveal(
                      child: AuthBrandMark(
                        subtitle: context.l10n.authLoginWelcome,
                      ),
                    ),*/
                    AppDimens.spacerLarge,
                    BicountReveal(
                      delay: const Duration(milliseconds: 70),
                      child: Image.asset(isDark ? AssetPaths.imageLoginDark : AssetPaths.imageLoginLight, height: 220),
                    ),
                    AppDimens.spacerLarge,
                    BicountReveal(
                      delay: const Duration(milliseconds: 120),
                      child: FieldsLogin(loading: state is SignInLoading),
                    ),
                    AppDimens.spacerMedium,
                    BicountReveal(
                      delay: const Duration(milliseconds: 170),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.authDontHaveAccount),
                          TextButton(
                            onPressed: () => GoRouter.of(context).go('/signUp'),
                            child: Text(
                              context.l10n.authSignUp,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppDimens.spacerLarge,
                    const BicountReveal(
                      delay: Duration(milliseconds: 220),
                      child: Separator(),
                    ),
                    AppDimens.spacerLarge,
                    BicountReveal(
                      delay: const Duration(milliseconds: 260),
                      child: CustomGoogleAuthButton(
                        isLogin: true,
                        isLoading: state is AuthWithGoogleLoading,
                        onPressed: () {
                          context.read<AuthentificationBloc>().add(
                            AuthWithGoogleEvent(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
