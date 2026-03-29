import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/presentation/cubit/locale_cubit.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/friend/presentation/screens/friends_directory_screen.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_event.dart';
import 'package:bicount/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:bicount/features/settings/presentation/helpers/settings_sheet_actions.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_header_card.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_pro_sheet.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_profile_sheet.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final data = state is MainLoaded
            ? state.startData
            : MainEntity.fromEmpty();
        final user = data.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BicountReveal(
                child: SettingsHeaderCard(
                  user: user,
                  subtitle: context.l10n.settingsHeaderSubtitle,
                ),
              ),
              BicountReveal(
                delay: const Duration(milliseconds: 50),
                child: SettingsSection(
                  title: context.l10n.settingsSectionAccount,
                  children: [
                    SettingsActionTile(
                      icon: Icons.person_outline,
                      title: context.l10n.settingsEditProfileTitle,
                      subtitle: context.l10n.settingsEditProfileDescription,
                      onTap: () => showSettingsSheet(
                        context,
                        SettingsProfileSheet(user: user),
                      ),
                    ),
                    SettingsActionTile(
                      icon: Icons.people_outline,
                      title: context.l10n.settingsFriendsTitle,
                      subtitle: context.l10n.settingsFriendsDescription,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FriendsDirectoryScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsActionTile(
                      icon: Icons.workspace_premium_outlined,
                      title: context.l10n.settingsProTitle,
                      subtitle: context.l10n.settingsProDescription,
                      onTap: () => showSettingsSheet(
                        context,
                        SettingsProSheet(defaultEmail: user.email),
                      ),
                    ),
                  ],
                ),
              ),
              BicountReveal(
                delay: const Duration(milliseconds: 100),
                child: SettingsSection(
                  title: context.l10n.settingsSectionAppearance,
                  children: [
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        return SettingsActionTile(
                          icon: Icons.palette_outlined,
                          title: context.l10n.settingsThemeTitle,
                          subtitle: context.l10n.settingsThemeDescription,
                          value: context.themePreferenceLabel(
                            themeState.preference,
                          ),
                          onTap: () =>
                              showThemeSettingsSheet(context, themeState),
                        );
                      },
                    ),
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return SettingsActionTile(
                          icon: Icons.language_outlined,
                          title: context.l10n.settingsLanguageTitle,
                          subtitle: context.l10n.settingsLanguageDescription,
                          value: context.localePreferenceLabel(
                            localeState.preference,
                          ),
                          onTap: () =>
                              showLanguageSettingsSheet(context, localeState),
                        );
                      },
                    ),
                    BlocBuilder<CurrencyCubit, CurrencyState>(
                      builder: (context, currencyState) {
                        return SettingsActionTile(
                          icon: Icons.currency_exchange_rounded,
                          title: context.l10n.settingsCurrencyTitle,
                          subtitle: context.l10n.settingsCurrencyDescription,
                          value:
                              '${currencyState.config.referenceCurrencyCode} · '
                              '${currencyState.config.currencyFor(currencyState.config.referenceCurrencyCode).symbol}',
                          onTap: () =>
                              showCurrencySettingsSheet(context, currencyState),
                        );
                      },
                    ),
                  ],
                ),
              ),
              BicountReveal(
                delay: const Duration(milliseconds: 150),
                child: SettingsSection(
                  title: context.l10n.settingsSectionSecurity,
                  children: [
                    SettingsActionTile(
                      icon: Icons.logout,
                      title: context.l10n.settingsSignOutTitle,
                      subtitle: context.l10n.settingsSignOutDescription,
                      onTap: () => context.read<SettingsBloc>().add(
                        const SettingsSignOutRequested(),
                      ),
                    ),
                    SettingsActionTile(
                      icon: Icons.delete_outline,
                      title: context.l10n.settingsDeleteTitle,
                      subtitle: context.l10n.settingsDeleteDescription,
                      danger: true,
                      onTap: () => confirmDeleteAccountRequest(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.marginLarge),
            ],
          ),
        );
      },
    );
  }
}
