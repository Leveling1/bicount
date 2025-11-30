import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../transaction/domain/entities/transaction_detail_args.dart';
import '../../../transaction/presentation/screens/detail_transaction_screen.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatelessWidget {
  final CardTapCallback? onCardTap;
  final MainEntity data;
  const HomeScreen({super.key, this.onCardTap, required this.data});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          NotificationHelper.showFailureNotification(context, state.message);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            height: height - AppDimens.bottomBarHeight.h,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppDimens.spacingMedium,
                  children: [
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.paddingExtraLarge,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "Your balance",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),

                              Text(
                                NumberFormatUtils.formatCurrency(
                                  data.user.profit != null
                                      ? data.user.profit!
                                      : 0.0,
                                ),
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Accounts",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CardTypeRevenue(
                            onTap: () {
                              onCardTap?.call(3);
                            },
                            label: "Personnal",
                            amount: data.user.personalIncome != null
                                ? data.user.personalIncome!
                                : 0.0,
                            icon: SvgPicture.asset(
                              IconLinks.user,
                              width: AppDimens.iconSizeSmall,
                              height: AppDimens.iconSizeSmall,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            color: Theme.of(
                              context,
                            ).extension<OtherTheme>()!.personnalIncome!,
                          ),
                        ),
                        const SizedBox(width: AppDimens.marginMedium),
                        Expanded(
                          flex: 1,
                          child: CardTypeRevenue(
                            onTap: () {
                              onCardTap?.call(1); // CompanyScreen
                            },
                            label: "Entreprises",
                            amount: data.user.companyIncome != null
                                ? data.user.companyIncome!
                                : 0.0,
                            icon: SvgPicture.asset(
                              IconLinks.company,
                              width: AppDimens.iconSizeSmall,
                              height: AppDimens.iconSizeSmall,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            color: Theme.of(
                              context,
                            ).extension<OtherTheme>()!.companyIncome!,
                          ),
                        ),
                      ],
                    ),
                    data.transactions.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transactions",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  onCardTap?.call(2); // TransactionScreen
                                },
                                style: Theme.of(context).textButtonTheme.style,
                                child: Text(
                                  "show more",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        itemCount: data.transactions.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final t = data.transactions[index];
                          final entity = TransactionEntity.fromTransaction(t);

                          return TransactionCard(
                            transaction: entity,
                            onTap: () {
                              showCustomBottomSheet(
                                context: context,
                                minHeight: 0.95,
                                color: null,
                                child: DetailTransaction(
                                  key: ValueKey(entity.tid),
                                  transaction: TransactionDetailArgs(
                                    user: data.user,
                                    transactionDetail: entity,
                                    friends: data.friends,
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
              },
            ),
          ),
        );
      },
    );
  }
}
