import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_suggestion_text_field.dart';
import 'package:flutter/material.dart';

class TransferFormBeneficiariesSection extends StatelessWidget {
  const TransferFormBeneficiariesSection({
    super.key,
    required this.beneficiaryController,
    required this.friendNames,
    required this.onAdd,
    this.validator,
  });

  final TextEditingController beneficiaryController;
  final List<String> friendNames;
  final VoidCallback onAdd;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transferBeneficiaries,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CustomSuggestionTextField(
          controller: beneficiaryController,
          onAdd: onAdd,
          isVisible: true,
          hintText: context.l10n.transferEnterBeneficiaryName,
          options: friendNames,
          validator: validator,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.transferBeneficiariesHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
