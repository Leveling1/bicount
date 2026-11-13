import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

part 'main_friend_aggregate.dart';

part 'main_friend_projection.dart';

class MainFinanceProjectionService {
  const MainFinanceProjectionService({
    this.currencyAmountService = const CurrencyAmountService(),
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService participantIdentityService;

  MainEntity project({
    required UserModel user,
    required List<FriendsModel> friends,
    required List<TransactionModel> transactions,
    required List<DebtModel> debts,
    required List<RecurringTransfertModel> recurringTransferts,
    required int connectionState,
    required CurrencyConfigEntity currencyConfig,
    Map<String, double>? walletTotals,
  }) {
    final relevantTransactions = participantIdentityService
        .filterTransactionsForCurrentUser(
          currentUserId: user.uid,
          friends: friends,
          transactions: transactions,
        );
    final currentUserParticipantIds = participantIdentityService
        .currentUserParticipantIds(currentUserId: user.uid, friends: friends);

    return MainEntity(
      user: _deriveUser(
        user,
        relevantTransactions,
        currencyConfig,
        currentUserParticipantIds,
        walletTotals,
      ),
      connectionState: connectionState,
      referenceCurrencyCode: currencyConfig.referenceCurrencyCode,
      friends: _deriveFriends(
        currentUserParticipantIds: currentUserParticipantIds,
        friends: friends,
        transactions: relevantTransactions,
        currencyConfig: currencyConfig,
      ),
      transactions: relevantTransactions,
      debts: debts,
      recurringTransferts: recurringTransferts,
    );
  }

  UserModel _deriveUser(
    UserModel user,
    List<TransactionModel> transactions,
    CurrencyConfigEntity currencyConfig,
    Set<String> currentUserParticipantIds,
    Map<String, double>? walletTotals,
  ) {
    // Net native (unconverted) amounts per currency first, then convert each
    // currency's net total exactly once. Converting every transaction
    // individually (each potentially using a different historical/cached FX
    // rate) before summing can leave a false non-zero residue even when the
    // underlying foreign-currency flows cancel out exactly.
    final balanceByCurrency = walletTotals ?? <String, double>{};
    final incomesByCurrency = <String, double>{};
    final expensesByCurrency = <String, double>{};
    final personalIncomeByCurrency = <String, double>{};
    final companyIncomeByCurrency = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionTypes.walletTransferCode) continue;
      final currencyCode = CurrencyConfigEntity.normalizeCode(
        transaction.currency,
      );
      final nativeAmount = transaction.amount;
      final category = transaction.category ?? Constants.personal;
      final selfMovement =
          transaction.senderId == transaction.beneficiaryId &&
          currentUserParticipantIds.contains(transaction.senderId);

      if (currentUserParticipantIds.contains(transaction.senderId) &&
          (!selfMovement || !TransactionTypes.isIncomeType(transaction.type))) {
        if (walletTotals == null) {
          _addNative(balanceByCurrency, currencyCode, -nativeAmount);
        }
        _addNative(expensesByCurrency, currencyCode, nativeAmount);
        if (category == Constants.personal) {
          _addNative(personalIncomeByCurrency, currencyCode, -nativeAmount);
        } else if (category == Constants.company) {
          _addNative(companyIncomeByCurrency, currencyCode, -nativeAmount);
        }
      }

      if (currentUserParticipantIds.contains(transaction.beneficiaryId) &&
          (!selfMovement ||
              !TransactionTypes.isExpenseType(transaction.type))) {
        if (walletTotals == null) {
          _addNative(balanceByCurrency, currencyCode, nativeAmount);
        }
        _addNative(incomesByCurrency, currencyCode, nativeAmount);
        if (category == Constants.personal) {
          _addNative(personalIncomeByCurrency, currencyCode, nativeAmount);
        } else if (category == Constants.company) {
          _addNative(companyIncomeByCurrency, currencyCode, nativeAmount);
        }
      }
    }

    return UserModel(
      uid: user.uid,
      image: user.image,
      username: user.username,
      email: user.email,
      balance: _convertNetByCurrency(balanceByCurrency, currencyConfig),
      incomes: _convertNetByCurrency(incomesByCurrency, currencyConfig),
      expenses: _convertNetByCurrency(expensesByCurrency, currencyConfig),
      companyIncome: _convertNetByCurrency(
        companyIncomeByCurrency,
        currencyConfig,
      ),
      personalIncome: _convertNetByCurrency(
        personalIncomeByCurrency,
        currencyConfig,
      ),
      referenceCurrencyCode: user.referenceCurrencyCode,
    );
  }

  void _addNative(
    Map<String, double> nativeAmountsByCurrency,
    String currencyCode,
    double delta,
  ) {
    nativeAmountsByCurrency[currencyCode] =
        (nativeAmountsByCurrency[currencyCode] ?? 0) + delta;
  }

  double _convertNetByCurrency(
    Map<String, double> nativeAmountsByCurrency,
    CurrencyConfigEntity currencyConfig,
  ) {
    var total = 0.0;
    for (final entry in nativeAmountsByCurrency.entries) {
      total += currencyAmountService.record(
        originalAmount: entry.value,
        originalCurrencyCode: entry.key,
        config: currencyConfig,
      );
    }
    return total;
  }
}
