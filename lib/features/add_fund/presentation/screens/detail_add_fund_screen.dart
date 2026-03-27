import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/presentation/widgets/account_funding_form.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailAddFundScreen extends StatefulWidget {
  const DetailAddFundScreen({super.key, required this.funding});

  final AccountFundingModel funding;

  @override
  State<DetailAddFundScreen> createState() => _DetailAddFundScreenState();
}

class _DetailAddFundScreenState extends State<DetailAddFundScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final funding = widget.funding;
    final fundingDate = DateTime.tryParse(funding.date) ?? DateTime.now();
    final createdAt =
        DateTime.tryParse(funding.createdAt ?? '') ?? fundingDate;

    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.transactionEditTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          AppDimens.spacerMedium,
          AccountFundingForm(
            initialFunding: funding,
            onCompleted: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).iconTheme.color,
                size: 20,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).cardColor,
          radius: 40,
          child: SizedBox(
            width: 50.w,
            height: 50.h,
            child: Icon(
              Icons.savings_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(funding.source, style: Theme.of(context).textTheme.headlineLarge),
        Text(
          '+ ${funding.amount} ${_resolveCurrencySymbol(funding.currency)}',
          style: TextStyle(
            color: AppColors.primaryColorDark,
            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          context.l10n.transactionTypeAddFund,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        DetailsCard(
          child: Column(
            children: [
              TransactionDetailRow(
                title: context.l10n.commonDate,
                content: formatedDate(fundingDate),
              ),
              const SizedBox(height: 8),
              TransactionDetailRow(
                title: context.l10n.commonTime,
                content: formatedTime(fundingDate),
              ),
            ],
          ),
        ),
        DetailsCard(
          child: Column(
            children: [
              TransactionDetailRow(
                title: context.l10n.commonSource,
                content: funding.source,
              ),
              const SizedBox(height: 8),
              TransactionDetailRow(
                title: context.l10n.accountFundingTypeTitle,
                content: context.accountFundingTypeLabel(funding.fundingType),
              ),
              if (funding.note?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                TransactionDetailRow(
                  title: context.l10n.commonNote,
                  content: funding.note!,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.commonCreatedAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              formatedDateTime(createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingLarge),
      ],
    );
  }

  String _resolveCurrencySymbol(String currencyCode) {
    try {
      return Currency.values.byName(currencyCode).symbol;
    } catch (_) {
      return currencyCode;
    }
  }
}
