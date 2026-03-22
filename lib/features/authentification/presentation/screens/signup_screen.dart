import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_brand_mark.dart';
import 'package:bicount/features/authentification/presentation/widgets/fields_signup.dart';
import 'package:bicount/features/authentification/presentation/widgets/separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/authentification_bloc.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthentificationBloc, AuthentificationState>(
        listener: (context, state) {
          if (state is SignUpFailure) {
            NotificationHelper.showFailureNotification(
              context,
              localizeRuntimeMessage(context, state.error),
            );
          } else if (state is SignUpSuccess) {
            GoRouter.of(context).go('/');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: AppDimens.paddingAllMedium,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BicountReveal(
                      child: AuthBrandMark(
                        subtitle: context.l10n.authSignupLead,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spacingLarge),
                    BicountReveal(
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.authSignUp,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            context.l10n.authSignupDescription,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.spacingLarge),
                    BicountReveal(
                      delay: const Duration(milliseconds: 130),
                      child: FieldsSignUp(loading: state is SignUpLoading),
                    ),
                    const SizedBox(height: AppDimens.spacingExtraLarge),
                    BicountReveal(
                      delay: const Duration(milliseconds: 180),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.authAlreadyHaveAccount),
                          TextButton(
                            onPressed: () => GoRouter.of(context).go('/login'),
                            child: Text(
                              context.l10n.authLogIn,
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
            ),
          );
        },
      ),
    );
  }
}
