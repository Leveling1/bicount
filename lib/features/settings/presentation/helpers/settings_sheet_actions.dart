import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/presentation/cubit/locale_cubit.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:bicount/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_delete_account_sheet.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showSettingsSheet(BuildContext context, Widget child) {
  showCustomBottomSheet(
    context: context,
    minHeight: 0.8,
    color: null,
    child: child,
  );
}

void showThemeSettingsSheet(BuildContext context, ThemeState state) {
  showSettingsSheet(
    context,
    SettingsOptionSheet<AppThemePreference>(
      title: context.l10n.settingsThemeSheetTitle,
      description: context.l10n.settingsThemeSheetDescription,
      selectedValue: state.preference,
      options: AppThemePreference.values,
      labelBuilder: context.themePreferenceLabel,
      onSelected: (value) => context.read<ThemeCubit>().selectPreference(value),
    ),
  );
}

void showLanguageSettingsSheet(BuildContext context, LocaleState state) {
  showSettingsSheet(
    context,
    SettingsOptionSheet<AppLocalePreference>(
      title: context.l10n.languageSheetTitle,
      description: context.l10n.settingsLanguageSheetDescription,
      selectedValue: state.preference,
      options: AppLocalePreference.values,
      labelBuilder: context.localePreferenceLabel,
      onSelected: (value) =>
          context.read<LocaleCubit>().selectPreference(value),
    ),
  );
}

Future<void> confirmDeleteAccountRequest(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: Theme.of(dialogContext).dialogTheme.shape,
      title: Text(context.l10n.settingsDeleteConfirmTitle),
      content: Text(context.l10n.settingsDeleteConfirmDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.commonReject),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.settingsDeleteConfirmCta),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    showSettingsSheet(context, const SettingsDeleteAccountSheet());
  }
}
