import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../domain/entities/transaction_model.dart';
import '../widgets/details_card.dart';

class DetailTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;
  const DetailTransactionScreen({super.key, required this.transaction});

  @override
  State<DetailTransactionScreen> createState() => _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  final double size = 20;

  @override
  Widget build(BuildContext context) {
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
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: AppDimens.paddingLarge, right: AppDimens.paddingLarge),
        child: SingleChildScrollView(
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
                  child: Image.asset(widget.transaction.image),
                ),
              ),
              DetailsCard(
                child: Text("data")
              )
            ]
          )
        ),
      ),
    );
  }
}

