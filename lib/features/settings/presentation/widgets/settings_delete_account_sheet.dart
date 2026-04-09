import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_event.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsDeleteAccountSheet extends StatefulWidget {
  const SettingsDeleteAccountSheet({super.key});

  @override
  State<SettingsDeleteAccountSheet> createState() =>
      _SettingsDeleteAccountSheetState();
}

class _SettingsDeleteAccountSheetState
    extends State<SettingsDeleteAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailsController = TextEditingController();
  String? _reasonCode;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _deleteReasons(context);

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback &&
          current.feedback?.action == SettingsPendingAction.deleteAccount &&
          current.feedback?.isError == false,
      listener: (context, state) => Navigator.of(context).pop(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsDeleteSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppDimens.spacerSmall,
                Text(
                  context.l10n.settingsDeleteSheetDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                AppDimens.spacerMedium,
                Text(
                  context.l10n.settingsDeleteReasonLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppDimens.spacerSmall,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.entries.map((entry) {
                    final selected = entry.key == _reasonCode;
                    return CustomChoiceChip(
                      label: entry.value,
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _reasonCode = entry.key),
                    );
                  }).toList(),
                ),
                AppDimens.spacerMedium,
                Text(
                  context.l10n.settingsDeleteDetailsLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppDimens.spacerSmall,
                TextFormField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: context.l10n.settingsDeleteDetailsHint,
                  ),
                ),
                AppDimens.spacerLarge,
                CustomButton(
                  text: context.l10n.settingsDeleteSubmit,
                  loading: state.isPending(SettingsPendingAction.deleteAccount),
                  onPressed: _submit,
                ),
                AppDimens.spacerLarge,
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, String> _deleteReasons(BuildContext context) {
    return {
      'missing_features': context.l10n.settingsDeleteReasonMissingFeatures,
      //'too_expensive': context.l10n.settingsDeleteReasonTooExpensive,
      'privacy': context.l10n.settingsDeleteReasonPrivacy,
      'too_complex': context.l10n.settingsDeleteReasonTooComplex,
      'not_useful': context.l10n.settingsDeleteReasonNotUseful,
      'other': context.l10n.settingsDeleteReasonOther,
    };
  }

  void _submit() {
    context.read<SettingsBloc>().add(
      SettingsDeleteAccountRequested(
        DeleteAccountRequestEntity(
          reasonCode: _reasonCode,
          details: _detailsController.text.trim(),
        ),
      ),
    );
  }
}
