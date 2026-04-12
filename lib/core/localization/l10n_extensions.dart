import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/presentation/cubit/locale_cubit.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:bicount/l10n/app_localizations.dart';

extension L10nBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String graphPeriodLabel(GraphPeriod period) {
    switch (period) {
      case GraphPeriod.week7:
        return '7D';
      case GraphPeriod.month30:
        return '30D';
      case GraphPeriod.quarter90:
        return '90D';
      case GraphPeriod.all:
        return l10n.graphPeriodAll;
    }
  }

  String graphBreakdownLabel(String label) {
    switch (label) {
      case 'AddFunds':
        return l10n.transactionTypeAddFund;
      case 'ReceivedTransfers':
        return l10n.transactionTypeIncome;
      case 'Expenses':
        return l10n.graphBreakdownExpenses;
      case 'Subscriptions':
        return l10n.graphBreakdownSubscriptions;
      case 'Other':
        return l10n.graphBreakdownOther;
      default:
        return label;
    }
  }

  String transactionTypeLabel(int type) {
    switch (type) {
      case TransactionTypes.incomeCode:
        return l10n.transactionTypeIncome;
      case TransactionTypes.expenseCode:
        return l10n.transactionTypeExpense;
      case TransactionTypes.subscriptionCode:
        return l10n.transactionTypeSubscription;
      case TransactionTypes.salaryCode:
        return l10n.transactionTypeSalary;
      default:
        return l10n.transactionTypeOther;
    }
  }

  String frequencyLabel(int frequency) {
    switch (frequency) {
      case Frequency.weekly:
        return l10n.frequencyWeekly;
      case Frequency.monthly:
        return l10n.frequencyMonthly;
      case Frequency.quarterly:
        return l10n.frequencyQuarterly;
      case Frequency.yearly:
        return l10n.frequencyYearly;
      case Frequency.oneTime:
      default:
        return l10n.frequencyOneTime;
    }
  }

  String accountFundingTypeLabel(int fundingType) {
    switch (fundingType) {
      case AccountFundingType.salary:
        return l10n.accountFundingTypeSalary;
      case AccountFundingType.other:
      default:
        return l10n.accountFundingTypeOther;
    }
  }

  String subscriptionStatusLabel(int status) {
    switch (SubscriptionConst.normalize(status)) {
      case SubscriptionConst.active:
        return l10n.graphActive;
      case SubscriptionConst.unsubscribed:
        return l10n.statusUnsubscribed;
      default:
        return l10n.statusPending;
    }
  }

  String transactionFilterLabel(int index) {
    switch (index) {
      case 0:
        return l10n.transactionFilterAll;
      case 1:
        return l10n.transactionFilterIncome;
      case 2:
        return l10n.transactionFilterExpense;
      case 3:
        return l10n.transactionFilterSubscription;
      case 4:
        return l10n.transactionFilterSalary;
      case 5:
        return l10n.transactionFilterOther;
      default:
        return l10n.transactionFilterOther;
    }
  }

  String salaryOccurrenceStateLabel(int state) {
    switch (AppSalaryOccurrenceState.normalize(state)) {
      case AppSalaryOccurrenceState.dueToday:
        return l10n.salaryStatusDueToday;
      case AppSalaryOccurrenceState.overdue:
        return l10n.salaryStatusOverdue;
      case AppSalaryOccurrenceState.received:
        return l10n.salaryStatusReceived;
      case AppSalaryOccurrenceState.upcoming:
      default:
        return l10n.salaryStatusUpcoming;
    }
  }

  String transactionDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) {
      return l10n.transactionToday;
    }
    if (_isSameDate(date, now.subtract(const Duration(days: 1)))) {
      return l10n.transactionYesterday;
    }
    return formatDate(date);
  }

  String friendInviteStatusLabel(int statusId) {
    switch (AppFriendInviteState.normalize(statusId)) {
      case AppFriendInviteState.pending:
        return l10n.statusPending;
      case AppFriendInviteState.accepted:
        return l10n.statusAccepted;
      case AppFriendInviteState.rejected:
        return l10n.statusRejected;
      case AppFriendInviteState.expired:
        return l10n.statusExpired;
      default:
        return l10n.statusPending;
    }
  }

  String splitModeLabel(TransactionSplitMode mode) {
    switch (mode) {
      case TransactionSplitMode.equal:
        return l10n.transactionSplitModeEqual;
      case TransactionSplitMode.percentage:
        return l10n.transactionSplitModePercentage;
      case TransactionSplitMode.customAmount:
        return l10n.transactionSplitModeCustom;
    }
  }

  String splitModeHelper(TransactionSplitMode mode) {
    switch (mode) {
      case TransactionSplitMode.equal:
        return l10n.transactionSplitHelperEqual;
      case TransactionSplitMode.percentage:
        return l10n.transactionSplitHelperPercentage;
      case TransactionSplitMode.customAmount:
        return l10n.transactionSplitHelperCustom;
    }
  }

  String localePreferenceLabel(AppLocalePreference preference) {
    switch (preference) {
      case AppLocalePreference.system:
        return l10n.languageSystem;
      case AppLocalePreference.english:
        return l10n.languageEnglish;
      case AppLocalePreference.french:
        return l10n.languageFrench;
    }
  }

  String themePreferenceLabel(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return l10n.settingsThemeSystem;
      case AppThemePreference.light:
        return l10n.settingsThemeLight;
      case AppThemePreference.dark:
        return l10n.settingsThemeDark;
    }
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
