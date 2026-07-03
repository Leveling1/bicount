part of '../expense_form.dart';

extension _ExpenseFormSections on _ExpenseFormState {
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
          TransferFormBeneficiariesSection(
            beneficiaryController: _beneficiary,
            friendNames: friendNames,
            onAdd: _addBeneficiary,
            validator: (value) {
              if (_beneficiaryList.isNotEmpty) {
                return null;
              }
              if (value == null || value.trim().isEmpty) {
                return context.l10n.validationFieldRequired;
              }
              return null;
            },
          ),

          if (_beneficiaryList.isNotEmpty) ...[
            AppDimens.spacerMedium,
            TransferFormBeneficiaryList(
              beneficiaries: _beneficiaryList,
              sharesByKey: splitPreview.sharesByKey,
              currency: selectedCurrency,
              beneficiaryKeyOf: beneficiaryKey,
              onRemove: _removeBeneficiary,
              splitMode: _splitMode,
              onSplitModeChanged: _onSplitModeChanged,
              splitControllerFor: splitControllerFor,
              onSplitValueChanged: _onSplitValueChanged,
              errorMessage: splitPreview.errorMessage,
            ),
          ],
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
        if (canEditAllFields && !_isRecurring) ...[
          AppDimens.spacerMedium,
          SmoothInsert(
            visible: !_isRecurring,
            child: TransferFormDebtSection(
              isDebt: _isDebt,
              subtitle: context.l10n.transactionDebtToggleSubtitleExpense,
              enabled: canEditAllFields,
              dueDateController: _debtDueDate,
              expectedAmountController: _debtExpectedRepaymentAmount,
              onDebtChanged: (value) {
              if (value && _beneficiaryList.length > 1) {
                NotificationHelper.showFailureNotification(
                  context,
                  context.l10n.transactionDebtSingleBeneficiaryOnly,
                );
                return;
              }

              _update(() {
                _isDebt = value;
                if (value) {
                  _isRecurring = false;
                }
              });
              },
            ),
          ),
        ],
        if (canEditAllFields && !_isDebt) ...[
          AppDimens.spacerMedium,
          SmoothInsert(
            visible: !_isDebt,
            child: TransferFormRecurringSection(
              isRecurring: _isRecurring,
              frequency: _recurringFrequency,
              recurringTypeId: _recurringTypeId,
              typeOptions: TransactionTypes.expenseTypes,
              subtitle: context.l10n.recurringToggleSubtitleExpense,
              enabled: canEditAllFields,
              onRecurringChanged: (value) => _update(() {
                _isRecurring = value;
                if (value) {
                  _isDebt = false;
                }
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
            ),
          ),
        ],
      ],
    );
  }
}
