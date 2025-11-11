import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../domain/entities/transaction_detail_args.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/widgets/details_card.dart';

class DetailTransaction extends StatelessWidget {
  final TransactionDetailArgs transaction;
  DetailTransaction({
    super.key,
    required this.transaction,
  });

  final double size = 20;
  late TransactionEntity data;
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    data = transaction.transactionDetail;
    String formattedDate = formatedDate(data.date);
    String formattedTime = formatedTime(data.date);
    String formattedCreatedDateTime = formatedDateTime(data.createdAt!);
    String sign = data.type == TransactionType.expense ? '-' : '+';
    String sender = transaction.friends
        .firstWhere((friend) => friend.sid == data.sender)
        .username;
    String beneficiary = transaction.friends
        .firstWhere((friend) => friend.sid == data.beneficiary)
        .username;

    return Column(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                data.sender == uid || data.uid == uid
                ? IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).iconTheme.color,
                    size: size,
                  ),
                ) : const SizedBox.shrink(),
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 40,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Image.asset(data.image!),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  '$sign ${data.amount} ${data.currency.symbol}',
                  style: TextStyle(
                    color: sign == "+"
                        ? AppColors.primaryColorDark
                        : AppColors.negativeColorDark,
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
                ),
                Text(
                  data.type.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(title: 'Date', content: formattedDate),
                      const SizedBox(height: 8),
                      RowDetail(title: 'Time', content: formattedTime),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(
                          title: 'Sender',
                          content: sender
                      ),
                      const SizedBox(height: 8),
                      RowDetail(
                        title: 'Beneficiary',
                        content: beneficiary,
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(
                        title: 'Frequency',
                        content: data.frequency!.name,
                      ),
                      const SizedBox(height: 8),
                      RowDetail(title: 'Note', content: data.note),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Created at', style: Theme.of(context).textTheme.bodySmall),
            Text(formattedCreatedDateTime, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class RowDetail extends StatelessWidget {
  final String title;
  final String content;

  const RowDetail({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium)
        ),
        Flexible(
          flex: 2,
          child: Text(content, style: Theme.of(context).textTheme.bodyMedium)
        ),
      ],
    );
  }
}
