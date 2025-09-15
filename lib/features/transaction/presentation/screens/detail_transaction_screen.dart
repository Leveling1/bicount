import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../domain/entities/transaction_model.dart';
import '../../../../core/widgets/details_card.dart';

class DetailTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionScreen({super.key, required this.transaction});

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  final double size = 20;
  late TransactionModel data;

  @override
  void initState() {
    data = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatedDate(data.date);
    String formattedTime = formatedTime(data.date);
    String formattedCreatedDateTime = formatedDateTime(data.createdAt!);
    String sign = data.type == Constants.expenseType ? '-' : '+';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SizedBox(
            width: 24,
            height: 24,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).iconTheme.color,
              size: size,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: AppDimens.paddingLarge,
          right: AppDimens.paddingLarge,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                  data.type.name,
                  style: TextStyle(
                    color: sign == "+"
                        ? AppColors.primaryColorDark
                        : AppColors.negativeColorDark,
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
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
                        title: 'Amount',
                        content: '$sign ${data.amount}',
                      ),
                    ],
                  ),
                ),
                DetailsCard(
                  child: Column(
                    children: [
                      RowDetail(title: 'Sender', content: data.sender),
                      const SizedBox(height: 8),
                      /*RowDetail(
                        title: 'Beneficiary',
                        content: data.beneficiary,
                      ),*/
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
                      RowDetail(
                        title: 'Created at',
                        content: formattedCreatedDateTime,
                      ),
                      const SizedBox(height: 8),
                      //RowDetail(title: 'Note', content: data.beneficiary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
