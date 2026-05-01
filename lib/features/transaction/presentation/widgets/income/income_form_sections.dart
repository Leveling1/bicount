part of '../income_form.dart';

extension _IncomeFormSections on _IncomeFormState {
  Widget _buildFormBody(
    BuildContext context, {
    required TransactionState state,
    required List<String> friendNames,
    required SplitPreviewResult splitPreview,
    required bool canEditAllFields,
  }) {
    return Column(
      children: [
        CustomAmountField(amount: _amount, currency: _currency),
        if (canEditAllFields) ...[
          AppDimens.spacerMedium,
          TransferFormPartySection(
            senderController: _sender,
            friendNames: friendNames,
          ),
        ],
        _buildPrimaryFields(context, friendNames),
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
        AppDimens.spacerMedium,
        CustomFormField(
          controller: _date,
          hint: context.l10n.commonDateHint,
          inputType: TextInputType.datetime,
          isDate: true,
          label: context.l10n.commonWhen,
        ),
        if (canEditAllFields) ...[
          AppDimens.spacerMedium,
          CustomFormField(
            controller: _name,
            label: context.l10n.commonTitle,
            hint: context.l10n.transferEnterTransactionName,
          ),
        ],
        AppDimens.spacerMedium,
        CustomFormField(
          controller: _note,
          label: context.l10n.commonNote,
          hint: context.l10n.commonPlaceholderNote,
          enableValidator: false,
        ),
        if (canEditAllFields) ...[
          AppDimens.spacerMedium,
          TransferFormRecurringSection(
            isRecurring: _isRecurring,
            frequency: _recurringFrequency,
            recurringTypeId: _recurringTypeId,
            salaryRequiresConfirmation:
                _recurringTypeId == TransactionTypes.salaryCode
                ? AppExecutionMode.requiresConfirmation(_recurringExecutionMode)
                : null,
            salaryReminderEnabled:
                _recurringTypeId == TransactionTypes.salaryCode
                ? _recurringReminderEnabled
                : null,
            typeOptions: TransactionTypes.incomeTypes,
            subtitle: context.l10n.recurringToggleSubtitleIncome,
            enabled: !_isEditing,
            onRecurringChanged: (value) => _update(() {
              _isRecurring = value;
              if (_name.text.isEmpty) {
                _name.text =
                    "${TransactionTypes.typeLabel(context, _recurringTypeId)} ${_beneficiaryList.isNotEmpty && _beneficiaryList.length == 1 ? _beneficiaryList[0].username : ""}";
              }
            }),
            onFrequencyChanged: (value) => _update(() {
              _recurringFrequency = value;
            }),
            onTypeChanged: (value) => _update(() {
              _recurringTypeId = value;
            }),
            onSalaryRequiresConfirmationChanged: (value) => _update(() {
              _recurringExecutionMode = value
                  ? AppExecutionMode.manualConfirmation
                  : AppExecutionMode.backendAutomatic;
              if (!value) {
                _recurringReminderEnabled = false;
              }
            }),
            onSalaryReminderChanged: (value) => _update(() {
              _recurringReminderEnabled = value;
            }),
          ),
        ],
      ],
    );
  }
}
