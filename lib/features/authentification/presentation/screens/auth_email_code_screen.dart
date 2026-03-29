import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_email_code_form.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthEmailCodeScreen extends StatelessWidget {
  const AuthEmailCodeScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthentificationBloc, AuthentificationState>(
          listener: (context, state) {
            if (state is VerifyEmailOtpSuccess) {
              context.go('/');
              return;
            }

            if (state is VerifyEmailOtpFailure) {
              NotificationHelper.showFailureNotification(
                context,
                localizeRuntimeMessage(context, state.error),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: AppDimens.paddingAllMedium,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BicountReveal(
                              child: Text(
                                context.l10n.authCheckYourEmailTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            AppDimens.spacerMedium,
                            BicountReveal(
                              delay: const Duration(milliseconds: 60),
                              child: Container(
                                padding: AppDimens.paddingAllMedium,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusLarge,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      context.l10n
                                          .authCheckYourEmailDescription(email),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    AppDimens.spacerMedium,
                                    AuthEmailCodeForm(
                                      loading: state is VerifyEmailOtpLoading,
                                      onVerify: (code) {
                                        context
                                            .read<AuthentificationBloc>()
                                            .add(
                                              VerifyEmailOtpEvent(
                                                email: email,
                                                code: code,
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppDimens.spacerMedium,
                            BicountReveal(
                              delay: const Duration(milliseconds: 120),
                              child: TextButton(
                                onPressed: () {
                                  final target = Uri(
                                    path: '/auth',
                                    queryParameters: {'email': email},
                                  ).toString();
                                  context.go(target);
                                },
                                child: Text(
                                  context.l10n.authChangeEmailAddress,
                                ),
                              ),
                            ),
                            AppDimens.spacerLarge,
                            const BicountReveal(
                              delay: Duration(milliseconds: 180),
                              child: AuthLegalLinks(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
