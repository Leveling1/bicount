part of 'l10n_extensions.dart';

extension L10nAnalysisLabels on BuildContext {
  String analysisPeriodLabel(AnalysisPeriod period) => period.label(this);

  String analysisBreakdownLabel(String label) {
    switch (label) {
      case 'AddFunds':
        return l10n.transactionTypeAddFund;
      case 'ReceivedTransfers':
        return l10n.transactionTypeIncome;
      case 'Income':
        return l10n.analysisIncome;
      case 'Salary':
        return l10n.transactionTypeSalary;
      case 'Expense':
      case 'Expenses':
        return l10n.analysisBreakdownExpenses;
      case 'Subscription':
      case 'Subscriptions':
        return l10n.analysisBreakdownSubscriptions;
      case 'Debt':
        return l10n.analysisBreakdownDebt;
      case 'Repayment':
      case 'Repayments':
        return l10n.analysisBreakdownRepayments;
      case 'Other':
        return l10n.analysisBreakdownOther;
      default:
        return label;
    }
  }
}
