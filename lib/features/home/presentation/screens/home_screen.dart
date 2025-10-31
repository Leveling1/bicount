import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/memoji_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/services/notification_helper.dart';
import '../bloc/home_bloc.dart';

typedef CardTapCallback = void Function(int index);

class HomeScreen extends StatefulWidget {
  final CardTapCallback? onCardTap;

  const HomeScreen({super.key, this.onCardTap});

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
    final double width = MediaQuery.sizeOf(context).width;
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
                                        ? state.data.profit as num
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
                                ? state.data.personalIncome!
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
                                ? state.data.companyIncome!
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              TransactionCard(
                                transaction: TransactionEntity(
                                  id: "01",
                                  name: MemojiUtils.defaultMemojis[index % 7].name!,
                                  type: TransactionType.income,
                                  date: DateTime.now(),
                                  createdAt: DateTime.now(),
                                  amount: 1250,
                                  image: MemojiUtils
                                      .defaultMemojis[index % 7]
                                      .imagePath,
                                  frequency: TransactionFrequency.cyclic,
                                  sender: "sender",
                                  beneficiary: {
                                    "0": "Jean Dupont",
                                    "1": "Alice Mambu",
                                  },
                                  note: "note",
                                  currency: Currency.EUR,
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).iconTheme.color,
                                thickness: 0.7,
                              ),
                            ],
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
    },);
  }
}