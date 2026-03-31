import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/presentation/bloc/add_fund_bloc.dart';
import 'package:bicount/features/add_fund/presentation/widgets/account_funding_form.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_actions.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final canManage = funding.sid == currentUserId;
    final fundingDate = DateTime.tryParse(funding.date) ?? DateTime.now();
    final createdAt = DateTime.tryParse(funding.createdAt ?? '') ?? fundingDate;
    final amount = NumberFormatUtils.formatCurrency(
      funding.amount,
      currencyCode: funding.currency,
    );

    return BlocConsumer<AddFundBloc, AddFundState>(
      listenWhen: (previous, current) =>
          current is AddFundDeleted ||
          (!_isEditing && current is AddFundFailure),
      listener: _onStateChanged,
      builder: (context, state) {
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
            if (canManage)
              TransactionDetailActions(
                iconSize: 20,
                isLoading: state is AddFundSaving,
                onDeletePressed: () => _confirmDelete(context),
                onEditPressed: () => setState(() => _isEditing = true),
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
            Text(
              funding.source,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              '+ $amount',
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
                    content: context.accountFundingTypeLabel(
                      funding.fundingType,
                    ),
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
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: Theme.of(dialogContext).dialogTheme.shape,
        title: Text(context.l10n.accountFundingDeleteConfirmTitle),
        content: Text(context.l10n.accountFundingDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonReject),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.accountFundingDeleteConfirmCta),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AddFundBloc>().add(
        AddFundDeleteRequested(funding: widget.funding),
      );
    }
  }

  void _onStateChanged(BuildContext context, AddFundState state) {
    if (state is AddFundDeleted) {
      NotificationHelper.showSuccessNotification(
        context,
        context.l10n.accountFundingDeletedSuccess,
      );
      Navigator.of(context).maybePop();
      return;
    }

    if (state is AddFundFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }
}
