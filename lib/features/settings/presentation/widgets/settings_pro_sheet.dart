import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_event.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class SettingsProSheet extends StatefulWidget {
  const SettingsProSheet({super.key, required this.defaultEmail});

  final String defaultEmail;

  @override
  State<SettingsProSheet> createState() => _SettingsProSheetState();
}

class _SettingsProSheetState extends State<SettingsProSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _useCaseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.defaultEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _organizationController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback &&
          current.feedback?.action == SettingsPendingAction.pro &&
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
                  context.l10n.settingsProSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.marginSmall),
                Text(
                  context.l10n.settingsProSheetDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimens.marginMedium),
                _SettingsField(
                  controller: _emailController,
                  label: context.l10n.settingsProContactEmailLabel,
                  hint: context.l10n.authYourEmailAddress,
                  inputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.validationEmailRequired;
                    }
                    if (!value.contains('@')) {
                      return context.l10n.validationInvalidEmail;
                    }
                    return null;
                  },
                ),
                _SettingsField(
                  controller: _organizationController,
                  label: context.l10n.settingsProOrganizationLabel,
                  hint: context.l10n.settingsProOrganizationHint,
                ),
                _SettingsField(
                  controller: _useCaseController,
                  label: context.l10n.settingsProUseCaseLabel,
                  hint: context.l10n.settingsProUseCaseHint,
                  maxLines: 4,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                CustomButton(
                  text: context.l10n.settingsProSubmit,
                  loading: state.isPending(SettingsPendingAction.pro),
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SettingsBloc>().add(
      SettingsProAccessRequested(
        ProUpgradeRequestEntity(
          requestId: const Uuid().v4(),
          contactEmail: _emailController.text.trim(),
          organizationName: _organizationController.text.trim(),
          useCase: _useCaseController.text.trim(),
        ),
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.controller,
    required this.label,
    required this.hint,
    this.inputType,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? inputType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppDimens.marginSmall),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}
