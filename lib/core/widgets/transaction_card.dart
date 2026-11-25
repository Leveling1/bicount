import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/transaction_direction_service.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../themes/app_dimens.dart';
import '../utils/formated_text.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final String? displayTitle;
  final TransactionDirection? walletTransferDirection;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.displayTitle,
    this.walletTransferDirection,
    this.onTap,
  });

  TransactionDirection _resolveDirection(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final mainState = context.watch<MainBloc>().state;
    final friends = mainState is MainLoaded
        ? mainState.startData.friends
        : const <FriendsModel>[];
    return const TransactionDirectionService().resolveFromEntity(
      transaction: transaction,
      currentUserId: uid,
      friends: friends,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sign = (walletTransferDirection ?? _resolveDirection(context)).symbol;

    Color? color = sign == "+"
        ? AppColors.primaryColorDark
        : sign == "-"
        ? AppColors.negativeColorDark
        : Theme.of(context).textTheme.bodyMedium!.color;

    IconData transactionIcon = sign == "+"
        ? Icons.arrow_downward
        : sign == "-"
        ? Icons.arrow_upward
        : Icons.more_horiz;

    String time = TimeOfDay.fromDateTime(transaction.date).format(context);
    final amount = NumberFormatUtils.formatCurrency(
      transaction.amount,
      currencyCode: transaction.currency,
    );

    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          customBorder: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          ),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: AppDimens.paddingSmallCard,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 20,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      transactionIcon,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                AppDimens.spacerWidthMediumSmall,

                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatedText().capitalizeFirstLetter(
                          displayTitle ?? transaction.name,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sign $amount',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      context.transactionTypeLabel(transaction.type),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
