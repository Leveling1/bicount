import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/core/widgets/custom_suggestion_text_field.dart';
import 'package:flutter/material.dart';

class TransferFormPartySection extends StatelessWidget {
  const TransferFormPartySection({
    super.key,
    required this.senderController,
    required this.dateController,
    required this.friendNames,
    required this.isCurrentUserSelected,
    required this.onCurrentUserChanged,
  });

  final TextEditingController senderController;
  final TextEditingController dateController;
  final List<String> friendNames;
  final bool isCurrentUserSelected;
  final ValueChanged<bool?> onCurrentUserChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.transferPaidBy,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    CustomSuggestionTextField(
                      controller: senderController,
                      hintText: context.l10n.transferEnterSenderName,
                      options: friendNames,
                      isVisible: false,
                    ),
                  ],
                ),
              ),
              AppDimens.spacerMediumSmall,
              Expanded(
                flex: 2,
                child: CustomFormField(
                  controller: dateController,
                  hint: context.l10n.commonDateHint,
                  inputType: TextInputType.datetime,
                  isDate: true,
                  label: context.l10n.commonWhen,
                ),
              ),
            ],
          ),
        ),
        CheckboxListTile(
          value: isCurrentUserSelected,
          onChanged: onCurrentUserChanged,
          title: Text(
            context.l10n.transferItsMePayer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
