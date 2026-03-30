import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_avatar.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_memoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendProfileSheet extends StatefulWidget {
  const FriendProfileSheet({super.key, required this.friend});

  final FriendsModel friend;

  @override
  State<FriendProfileSheet> createState() => _FriendProfileSheetState();
}

class _FriendProfileSheetState extends State<FriendProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.friend.username);
    _selectedImage = widget.friend.image.isEmpty
        ? Constants.memojiDefault
        : widget.friend.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.friendEditTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppDimens.spacerSmall,
          Text(
            context.l10n.friendEditDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          AppDimens.spacerMedium,
          Center(
            child: SettingsAvatar(
              image: _selectedImage,
              radius: AppDimens.settingsAvatarPreviewRadius,
            ),
          ),
          AppDimens.spacerMedium,
          Text(
            context.l10n.settingsProfileNameLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppDimens.spacerSmall,
          TextFormField(
            controller: _nameController,
            validator: (value) => (value == null || value.trim().length < 2)
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
          SettingsMemojiPicker(
            repository: context.read<SettingsRepositoryImpl>(),
            selectedImage: _selectedImage,
            onSelected: (image) => setState(() => _selectedImage = image),
          ),
          AppDimens.spacerLarge,
          CustomButton(
            text: context.l10n.settingsProfileSave,
            loading: _isSaving,
            onPressed: _submit,
          ),
          AppDimens.spacerLarge,
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<FriendRepositoryImpl>().updateFriendProfile(
        friend: widget.friend,
        username: _nameController.text.trim(),
        image: _selectedImage,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.runtimeFriendUpdateFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
