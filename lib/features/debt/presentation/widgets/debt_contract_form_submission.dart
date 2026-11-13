part of 'debt_contract_form.dart';

extension on _DebtContractFormState {
  double? _parseAmount(String? value) {
    return double.tryParse(
      (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
    );
  }

  void _syncExpectedAmountFromPrincipal() {
    if (!_syncExpectedToPrincipal || _isPatchingExpectedAmount) return;
    if (_expectedAmountController.text == _amountController.text) {
      return;
    }
    _isPatchingExpectedAmount = true;
    _expectedAmountController.text = _amountController.text;
    _isPatchingExpectedAmount = false;
  }

  void _trackExpectedAmountMode() {
    if (_isPatchingExpectedAmount) return;
    final expectedText = _expectedAmountController.text.trim();
    _syncExpectedToPrincipal =
        expectedText.isEmpty ||
        _parseAmount(expectedText) == _parseAmount(_amountController.text);
  }
}
