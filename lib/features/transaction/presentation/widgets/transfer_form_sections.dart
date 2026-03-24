part of 'transfer_form.dart';

extension _TransferFormSections on _TransferFormState {
  Widget _buildFormBody(
    BuildContext context, {
    required TransactionState state,
    required List<String> friendNames,
    required SplitPreviewResult splitPreview,
  }) {
    return Column(
      children: [
        _buildPrimaryFields(context, friendNames),
        if (_beneficiaryList.isNotEmpty) ...[
          AppDimens.spacerMedium,
          TransferFormBeneficiaryList(
            beneficiaries: _beneficiaryList,
            sharesByKey: splitPreview.sharesByKey,
            currency: _selectedCurrency,
            beneficiaryKeyOf: _beneficiaryKey,
            onRemove: _removeBeneficiary,
          ),
          if (!_isEditing) ...[
            AppDimens.spacerSmall,
            TransferFormSplitModeSection(
              splitMode: _splitMode,
              onChanged: _onSplitModeChanged,
            ),
            AppDimens.spacerMediumSmall,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.splitModeHelper(_splitMode),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          ..._buildSplitInputSection(context),
          AppDimens.spacerMediumSmall,
          TransferFormPreviewCard(
            preview: splitPreview,
            splitMode: _splitMode,
            currency: _selectedCurrency,
          ),
        ],
        AppDimens.spacerExtraLarge,
        CustomButton(
          text: context.l10n.commonSave,
          loading: state is TransactionLoading,
          onPressed: _submit,
        ),
        AppDimens.spacerExtraLarge,
      ],
    );
  }

  Widget _buildPrimaryFields(BuildContext context, List<String> friendNames) {
    return Column(
      children: [
        CustomFormField(
          controller: _name,
          label: context.l10n.commonTitle,
          hint: context.l10n.transferEnterTransactionName,
        ),
        AppDimens.spacerMedium,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.commonAmount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            CustomAmountField(amount: _amount, currency: _currency),
          ],
        ),
        AppDimens.spacerMedium,
        CustomFormField(
          controller: _note,
          label: context.l10n.commonNote,
          hint: context.l10n.commonPlaceholderNote,
          enableValidator: false,
        ),
        AppDimens.spacerMedium,
        TransferFormPartySection(
          senderController: _sender,
          dateController: _date,
          friendNames: friendNames,
          isCurrentUserSelected: _isCurrentUserAlias(_sender.text),
          onCurrentUserChanged: _onCurrentUserChanged,
        ),
        AppDimens.spacerMedium,
        TransferFormBeneficiariesSection(
          beneficiaryController: _beneficiary,
          friendNames: friendNames,
          onAdd: _addBeneficiary,
        ),
      ],
    );
  }

  List<Widget> _buildSplitInputSection(BuildContext context) {
    if (_isEditing || _splitMode == TransactionSplitMode.equal) {
      return const [];
    }

    return [
      AppDimens.spacerMediumSmall,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.transactionSplitDetails,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: _resetSplitInputs,
            child: Text(context.l10n.transactionSplitEqually),
          ),
        ],
      ),
      AppDimens.spacerSmall,
      ..._beneficiaryList.map((friend) {
        final controller = _splitControllerFor(friend);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SplitInputRow(
            friend: friend,
            controller: controller,
            mode: _splitMode,
            currency: _selectedCurrency,
            onChanged: _onSplitValueChanged,
          ),
        );
      }),
    ];
  }
}
