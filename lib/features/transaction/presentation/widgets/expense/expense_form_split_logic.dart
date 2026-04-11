part of '../expense_form.dart';

extension _ExpenseFormSplitLogic on _ExpenseFormState {
  void _seedSplitInputsForCurrentMode({required bool overwrite}) {
    if (_beneficiaryList.isEmpty) {
      return;
    }

    if (_splitMode == TransactionSplitMode.percentage) {
      final count = _beneficiaryList.length;
      var distributed = 0.0;
      for (var index = 0; index < _beneficiaryList.length; index++) {
        final friend = _beneficiaryList[index];
        final controller = splitControllerFor(friend);
        if (!overwrite && controller.text.trim().isNotEmpty) {
          continue;
        }

        final value = index == count - 1
            ? (100 - distributed)
            : double.parse((100 / count).toStringAsFixed(2));
        distributed += value;
        controller.text = value.toStringAsFixed(2);
      }
      return;
    }

    if (_splitMode == TransactionSplitMode.customAmount) {
      final totalAmount = parseAmount(_amount.text);
      if (totalAmount == null || totalAmount <= 0) {
        return;
      }

      final equalShares = _splitResolver.resolve(
        CreateTransactionRequestEntity(
          name: _name.text.trim().isEmpty
              ? context.l10n.commonPreview
              : _name.text.trim(),
          date: resolveTransactionDate(),
          totalAmount: totalAmount,
          currency: selectedCurrency,
          sender: widget.user != null
              ? toCurrentUserParty()
              : _beneficiaryList.first,
          note: _note.text.trim(),
          transactionType: transactionFormType,
          splitMode: TransactionSplitMode.equal,
          splits: _beneficiaryList
              .map((friend) => TransactionSplitInputEntity(beneficiary: friend))
              .toList(),
        ),
      );

      for (final share in equalShares) {
        final controller = splitControllerFor(share.beneficiary);
        if (!overwrite && controller.text.trim().isNotEmpty) {
          continue;
        }
        controller.text = share.amount.toStringAsFixed(2);
      }
    }
  }

  SplitPreviewResult _buildPreview() {
    if (_beneficiaryList.isEmpty) {
      return const SplitPreviewResult(
        resolvedSplits: <ResolvedTransactionSplitEntity>[],
        sharesByKey: <String, ResolvedTransactionSplitEntity>{},
      );
    }

    final totalAmount = parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      return SplitPreviewResult(
        resolvedSplits: const <ResolvedTransactionSplitEntity>[],
        sharesByKey: const <String, ResolvedTransactionSplitEntity>{},
        errorMessage: context.l10n.transactionPreviewEnterValidTotal,
      );
    }

    try {
      final resolved = _splitResolver.resolve(
        CreateTransactionRequestEntity(
          name: _name.text.trim().isEmpty
              ? context.l10n.commonPreview
              : _name.text.trim(),
          date: resolveTransactionDate(),
          totalAmount: totalAmount,
          currency: selectedCurrency,
          sender: widget.user != null
              ? toCurrentUserParty()
              : _beneficiaryList.first,
          note: _note.text.trim(),
          transactionType: transactionFormType,
          splitMode: _splitMode,
          splits: _buildSplitInputs(),
        ),
      );

      return SplitPreviewResult(
        resolvedSplits: resolved,
        sharesByKey: {
          for (final split in resolved)
            beneficiaryKey(split.beneficiary): split,
        },
      );
    } on MessageFailure catch (error) {
      return SplitPreviewResult(
        resolvedSplits: const <ResolvedTransactionSplitEntity>[],
        sharesByKey: const <String, ResolvedTransactionSplitEntity>{},
        errorMessage: error.message,
      );
    }
  }
}
