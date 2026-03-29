import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_event.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_state.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        final feedback = state.feedback;
        if (feedback == null) {
          return;
        }

        final message = feedback.isError
            ? localizeRuntimeMessage(context, feedback.message)
            : _successMessage(context, feedback.action);

        if (feedback.isError) {
          NotificationHelper.showFailureNotification(context, message);
        } else {
          NotificationHelper.showSuccessNotification(context, message);
        }

        context.read<SettingsBloc>().add(const SettingsFeedbackConsumed());
      },
      child: Scaffold(
        appBar: CustomAppBar(title: context.l10n.settingsTitle),
        body: const SettingsContent(),
      ),
    );
  }

  String _successMessage(BuildContext context, SettingsPendingAction action) {
    switch (action) {
      case SettingsPendingAction.profile:
        return context.l10n.settingsProfileUpdatedSuccess;
      case SettingsPendingAction.pro:
        return context.l10n.settingsProRequestedSuccess;
      case SettingsPendingAction.signOut:
        return context.l10n.settingsSignedOutSuccess;
      case SettingsPendingAction.deleteAccount:
        return context.l10n.settingsDeleteRequestedSuccess;
    }
  }
}
