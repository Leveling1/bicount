import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:uuid/uuid.dart';

import 'offline_finance_delta_calculator.dart';

class OfflineFinanceLocalService {
  OfflineFinanceLocalService({
    OfflineFinanceDeltaCalculator calculator =
        const OfflineFinanceDeltaCalculator(),
  }) : _calculator = calculator;

  final OfflineFinanceDeltaCalculator _calculator;

  Future<void> applyTransactionEffects({
    required String currentUserId,
    required TransactionModel transaction,
  }) async {
    final category = transaction.category ?? Constants.personal;
    await _applyTransactionSide(
      currentUserId: currentUserId,
      partyId: transaction.senderId,
      amount: transaction.amount,
      category: category,
      isSender: true,
    );
    await _applyTransactionSide(
      currentUserId: currentUserId,
      partyId: transaction.beneficiaryId,
      amount: transaction.amount,
      category: category,
      isSender: false,
    );
  }

  Future<void> applyFundingEffects(AccountFundingModel funding) async {
    if (funding.category == Constants.personal) {
      final user = await _findUser(funding.sid);
      if (user == null) return;
      await Repository().upsert<UserModel>(
        _calculator.applyPersonalFundingToUser(
          user: user,
          amount: funding.amount,
        ),
      );
      return;
    }

    final company = await _findCompany(funding.sid);
    if (company == null) return;
    await Repository().upsert<CompanyModel>(
      _calculator.applyCompanyFundingToCompany(
        company: company,
        amount: funding.amount,
      ),
    );
  }

  Future<void> createSubscriptionWithEffects({
    required String currentUserId,
    required SubscriptionModel subscription,
  }) async {
    await Repository().upsert<SubscriptionModel>(subscription);
    final subscriptionId = subscription.subscriptionId;
    if (subscriptionId == null || subscriptionId.isEmpty) {
      throw MessageFailure(message: 'Subscription identifier is missing.');
    }

    final existingFriend = await _findFriend(subscriptionId);
    await Repository().upsert<FriendsModel>(
      FriendsModel(
        sid: subscriptionId,
        uid: null,
        fid: currentUserId,
        username: subscription.title,
        email: existingFriend?.email ?? '',
        image: existingFriend?.image ?? '',
        give: existingFriend?.give ?? 0,
        receive: existingFriend?.receive ?? 0,
        relationType: FriendConst.subscription,
        personalIncome: existingFriend?.personalIncome ?? 0,
        companyIncome: existingFriend?.companyIncome ?? 0,
      ),
    );

    final existingTransaction = await _findSubscriptionTransaction(
      currentUserId,
      subscriptionId,
    );
    if (existingTransaction != null) return;

    final generatedTransaction = TransactionModel(
      uid: currentUserId,
      gtid: const Uuid().v4(),
      name: subscription.title,
      type: TransactionTypes.subscriptionCode,
      beneficiaryId: subscriptionId,
      senderId: currentUserId,
      date: subscription.startDate,
      note: subscription.notes ?? '',
      amount: subscription.amount,
      currency: subscription.currency,
      image: '',
      frequency: subscription.frequency,
      category: subscription.category ?? Constants.personal,
      createdAt: subscription.createdAt,
    );
    await Repository().upsert<TransactionModel>(generatedTransaction);
    await applyTransactionEffects(
      currentUserId: currentUserId,
      transaction: generatedTransaction,
    );
  }

  Future<void> _applyTransactionSide({
    required String currentUserId,
    required String partyId,
    required double amount,
    required int category,
    required bool isSender,
  }) async {
    if (partyId == currentUserId) {
      final user = await _findUser(currentUserId);
      if (user == null) return;
      await Repository().upsert<UserModel>(
        _calculator.applyTransactionToUser(
          user: user,
          isSender: isSender,
          amount: amount,
          category: category,
        ),
      );
      return;
    }
  }

  Future<UserModel?> _findUser(String uid) => _firstOrNull(
    Repository().get<UserModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('uid', uid)]),
    ),
  );

  Future<FriendsModel?> _findFriend(String sid) => _firstOrNull(
    Repository().get<FriendsModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('sid', sid)]),
    ),
  );

  Future<CompanyModel?> _findCompany(String cid) => _firstOrNull(
    Repository().get<CompanyModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('cid', cid)]),
    ),
  );

  Future<TransactionModel?> _findSubscriptionTransaction(
    String currentUserId,
    String subscriptionId,
  ) => _firstOrNull(
    Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(
        where: [
          Where.exact('senderId', currentUserId),
          Where.exact('beneficiaryId', subscriptionId),
          Where.exact('type', TransactionTypes.subscriptionCode),
        ],
      ),
    ),
  );

  Future<T?> _firstOrNull<T>(Future<List<T>> future) async {
    final items = await future;
    return items.isEmpty ? null : items.first;
  }
}
