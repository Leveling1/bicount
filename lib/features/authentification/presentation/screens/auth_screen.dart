import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/routes/friend_invite_route.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_brand_mark.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_email_request_form.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, this.initialEmail, this.initialInviteCode});

  final String? initialEmail;
  final String? initialInviteCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthentificationBloc, AuthentificationState>(
          listener: (context, state) {
            if (state is RequestEmailOtpSuccess) {
              final target = Uri(
                path: '/auth/email-code',
                queryParameters: {
                  'email': state.email,
                  if (initialInviteCode != null &&
                      initialInviteCode!.trim().isNotEmpty)
                    'inviteCode': initialInviteCode,
                },
              ).toString();
              context.go(target);
              return;
            }

            if (state is AuthWithGoogleSuccess) {
              context.go(_resolvePostAuthRoute());
              return;
            }

            if (state is AuthWithAppleSuccess) {
              context.go(_resolvePostAuthRoute());
              return;
            }

            final error = switch (state) {
              RequestEmailOtpFailure() => state.error,
              AuthWithGoogleFailure() => state.error,
              AuthWithAppleFailure() => state.error,
              _ => null,
            };
            if (error != null) {
              NotificationHelper.showFailureNotification(
                context,
                localizeRuntimeMessage(context, error),
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
                            const BicountReveal(child: AuthBrandMark()),
                            AppDimens.spacerExtraLarge,
                            BicountReveal(
                              delay: const Duration(milliseconds: 60),
                              child: Column(
                                children: [
                                  Text(
                                    context.l10n.authUnifiedTitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(
                                    height: AppDimens.spacingSmall,
                                  ),
                                  Text(
                                    context.l10n.authUnifiedSubtitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            AppDimens.spacerExtraLarge,
                            BicountReveal(
                              delay: const Duration(milliseconds: 120),
                              child: CustomGoogleAuthButton(
                                isLoading: state is AuthWithGoogleLoading,
                                onPressed: () {
                                  context.read<AuthentificationBloc>().add(
                                    AuthWithGoogleEvent(),
                                  );
                                },
                              ),
                            ),
                            if (_showsAppleButton)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppDimens.spacingMedium,
                                ),
                                child: BicountReveal(
                                  delay: const Duration(milliseconds: 160),
                                  child: CustomAppleAuthButton(
                                    isLoading: state is AuthWithAppleLoading,
                                    onPressed: () {
                                      context.read<AuthentificationBloc>().add(
                                        AuthWithAppleEvent(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            AppDimens.spacerLarge,
                            BicountReveal(
                              delay: const Duration(milliseconds: 210),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.spacingMedium,
                                    ),
                                    child: Text(context.l10n.authOr),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                            ),
                            AppDimens.spacerLarge,
                            BicountReveal(
                              delay: const Duration(milliseconds: 260),
                              child: AuthEmailRequestForm(
                                loading: state is RequestEmailOtpLoading,
                                initialEmail: initialEmail,
                                onSubmit: (email) {
                                  context.read<AuthentificationBloc>().add(
                                    RequestEmailOtpEvent(email: email),
                                  );
                                },
                              ),
                            ),
                            AppDimens.spacerLarge,
                            const BicountReveal(
                              delay: Duration(milliseconds: 320),
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

  bool get _showsAppleButton {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  String _resolvePostAuthRoute() {
    final inviteCode = initialInviteCode?.trim();
    if (inviteCode == null || inviteCode.isEmpty) {
      return '/';
    }
    return FriendInviteRoute.buildShellRoute(inviteCode);
  }
}
