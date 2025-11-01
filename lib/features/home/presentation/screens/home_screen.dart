import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/memoji_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../transaction/data/models/transaction.model.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatefulWidget {
  final CardTapCallback? onCardTap;
  final List<TransactionModel> transactions;
  const HomeScreen({super.key, this.onCardTap, required this.transactions});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // Ici on déclenche la récupération des companies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(GetAllData());
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state){
        if (state is HomeError) {
          NotificationHelper.showFailureNotification(context, state.message);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: SizedBox(
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
                                    state is HomeLoading
                                      ? 0.0
                                      : state is HomeLoaded
                                        ? state.data.ownData.profit as num
                                        : 0.0
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
                    SizedBox(
                      height: 155.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CardTypeRevenue(
                            onTap: () { },
                            label: "Personnal",
                            amount: state is HomeLoading
                                ? 0.0
                                : state is HomeLoaded
                                ? state.data.ownData.personalIncome!
                                : 0.0,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser03,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: AppDimens.spacingMedium),
                          CardTypeRevenue(
                            onTap: () {
                              widget.onCardTap?.call(1); // CompanyScreen
                            },
                            label: "Entreprises",
                            amount: state is HomeLoading
                              ? 0.0
                              : state is HomeLoaded
                                ? state.data.ownData.companyIncome!
                                : 0.0,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedBuilding02,
                              color: Colors.white,
                            ),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transactions",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onCardTap?.call(2); // TransactionScreen
                          },
                          style: Theme.of(context).textButtonTheme.style,
                          child: Text(
                            "show more",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    state is HomeLoading ? const CircularProgressIndicator()
                      : state is HomeLoaded
                        ? Expanded(
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Column(
                                children:
                                widget.transactions.map((transaction) {
                                  final transactionEntity = TransactionEntity.fromTransaction(transaction);
                                  return TransactionCard(transaction: transactionEntity);
                                }).toList(),
                              );
                            },
                          ),
                        )
                      : Column(
                      children: [
                        Text("No data"),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
    },);
  }
}