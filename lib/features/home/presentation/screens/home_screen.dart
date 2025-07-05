import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/home_bloc.dart';
import 'package:bicount/core/widgets/container_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).bottomNavigationBarTheme.backgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: height - AppDimens.bottomBarHeight.h,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return ContainerBody(
                child: Column(
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
                                NumberFormatUtils.formatCurrency(86290.49),
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
                      height: 130.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              width: 180.w,
                              decoration: BoxDecoration(
                                gradient: AppColors.cardLinearGradientLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.borderRadiusLarge,
                                ),
                                border: Border.all(color: Colors.grey),
                              ),

                              padding: AppDimens.paddingAllMedium,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppDimens.spacingMedium,
                                children: [
                                  Container(
                                    padding: AppDimens.paddingAllSmall,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person),
                                  ),
                                  Text(
                                    NumberFormatUtils.formatCurrency(5695.20),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Personal",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
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
                          onPressed: () {},
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
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Container(height: 50, color: Colors.amber);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
