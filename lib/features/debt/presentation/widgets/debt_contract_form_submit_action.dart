part of 'debt_contract_form.dart';

extension on _DebtContractFormState {
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final principalAmount = _parseAmount(_amountController.text);
    final expectedAmount =
        _parseAmount(_expectedAmountController.text) ?? principalAmount;
    if (principalAmount == null || expectedAmount == null) {
      return;
    }

    widget.onSubmit(
      UpdateDebtRequestEntity(
        debtId: widget.debt.debtId ?? '',
        walletId: _walletId,
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        principalDate: resolveFormDateToIso(_dateController.text),
        principalAmount: principalAmount,
        currency: _currencyController.text.trim().toUpperCase(),
        dueDate: resolveFormDateToIso(_dueDateController.text),
        expectedRepaymentAmount: expectedAmount,
      ),
    );
  }
}
