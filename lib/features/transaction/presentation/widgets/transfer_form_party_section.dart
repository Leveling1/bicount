import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_suggestion_text_field.dart';
import 'package:flutter/material.dart';

class TransferFormPartySection extends StatelessWidget {
  const TransferFormPartySection({
    super.key,
    required this.senderController,
    required this.friendNames,
  });

  final TextEditingController senderController;
  final List<String> friendNames;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
