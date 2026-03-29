import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/friend/domain/entities/friend_detail_entity.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_detail_args.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/presentation/screens/detail_transaction_screen.dart';
import 'package:flutter/material.dart';

class DetailFriendTransactionSection extends StatelessWidget {
  const DetailFriendTransactionSection({
    super.key,
    required this.detail,
    required this.user,
    required this.friends,
  });

  final FriendDetailEntity detail;
  final UserModel user;
  final List<FriendsModel> friends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.friendSharedTransactions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimens.marginSmall),
        DetailsCard(
          child: detail.transactions.isEmpty
              ? Text(
                  context.l10n.friendTransactionsEmpty,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detail.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entity = TransactionEntity.fromTransaction(
                      detail.transactions[index],
                    );
                    return TransactionCard(
                      transaction: entity,
                      onTap: () {
                        showCustomBottomSheet(
                          context: context,
                          minHeight: 0.95,
                          color: null,
                          child: DetailTransactionScreen(
                            key: ValueKey(entity.tid),
                            transaction: TransactionDetailArgs(
                              user: user,
                              transactionDetail: entity,
                              friends: friends,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
