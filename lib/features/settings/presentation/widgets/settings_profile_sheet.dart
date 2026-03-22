import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/settings/domain/entities/settings_profile_update_entity.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_event.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_state.dart';
import 'package:bicount/features/settings/presentation/helpers/settings_avatar_catalog.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsProfileSheet extends StatefulWidget {
  const SettingsProfileSheet({super.key, required this.user});

  final UserModel user;

  @override
  State<SettingsProfileSheet> createState() => _SettingsProfileSheetState();
}

class _SettingsProfileSheetState extends State<SettingsProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.username);
    _selectedImage = widget.user.image.isEmpty
        ? SettingsAvatarCatalog.avatarUrls.first
        : widget.user.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback &&
          current.feedback?.action == SettingsPendingAction.profile &&
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
                  context.l10n.settingsProfileSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppDimens.spacerSmall,
                Text(
                  context.l10n.settingsProfileSheetDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                AppDimens.spacerMedium,
                Text(
                  context.l10n.settingsProfileNameLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppDimens.spacerSmall,
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      (value == null || value.trim().length < 2)
                      ? context.l10n.validationTooShort
                      : null,
                  decoration: InputDecoration(
                    hintText: context.l10n.settingsProfileNameHint,
                  ),
                ),
                AppDimens.spacerMedium,
                Text(
                  context.l10n.settingsProfileAvatarLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppDimens.spacerSmall,
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: SettingsAvatarCatalog.avatarUrls.map((image) {
                    final selected = image == _selectedImage;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImage = image),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        scale: selected ? 1.04 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: SettingsAvatar(image: image, radius: 22),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppDimens.spacerLarge,
                CustomButton(
                  text: context.l10n.settingsProfileSave,
                  loading: state.isPending(SettingsPendingAction.profile),
                  onPressed: _submit,
                ),
                AppDimens.spacerLarge
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
      SettingsProfileUpdatedRequested(
        SettingsProfileUpdateEntity(
          username: _nameController.text.trim(),
          image: _selectedImage,
        ),
      ),
    );
  }
}
