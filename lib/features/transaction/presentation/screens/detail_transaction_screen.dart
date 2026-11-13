import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/core/services/open_occurrence_sheet.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/confirm_delete.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/data/repositories/debt_repository_impl.dart';
import 'package:bicount/features/debt/domain/services/debt_view_service.dart';
import 'package:bicount/features/debt/presentation/bloc/debt_bloc.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_contract_form.dart';
import 'package:bicount/features/debt/presentation/screens/debt_screen_helpers.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_content.dart';
import 'package:bicount/features/transaction/presentation/widgets/expense_form.dart';
import 'package:bicount/features/transaction/presentation/widgets/income_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/transaction_detail_args.dart';

part 'detail_transaction_actions.dart';

part 'detail_transaction_related_operations.dart';

class DetailTransactionScreen extends StatefulWidget {
  const DetailTransactionScreen({super.key, required this.transaction});

  final TransactionDetailArgs transaction;

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final transactionDetail = widget.transaction.transactionDetail;
    final principalDebt = _principalDebt;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final canManage = transactionDetail.uid == uid;

    if (principalDebt != null) {
      final canManageDebt = principalDebt.createdBy == uid;
      return BlocProvider(
        create: (context) => DebtBloc(context.read<DebtRepositoryImpl>()),
        child: BlocConsumer<DebtBloc, DebtState>(
          listenWhen: (previous, current) =>
              current is DebtActionSuccess || current is DebtActionFailure,
          listener: _onDebtStateChanged,
          builder: (context, state) {
            final isLoading =
                state is DebtActionInProgress &&
                state.targetId == principalDebt.debtId;

            if (_isEditing) {
              return DebtContractForm(
                debt: principalDebt,
                isLender: const TransactionParticipantIdentityService()
                    .currentUserParticipantIds(
                      currentUserId: uid,
                      friends: widget.transaction.friends,
                    )
                    .contains(principalDebt.lenderId),
                principalTransaction: transactionDetail,
                counterpartyName: _resolveCounterpartyName(principalDebt),
                isLoading: isLoading,
                onSubmit: (request) {
                  context.read<DebtBloc>().add(UpdateDebtRequested(request));
                },
                onCancel: () => setState(() => _isEditing = false),
              );
            }

            return TransactionDetailContent(
              transaction: widget.transaction,
              canManage: canManageDebt,
              isLoading: isLoading,
              debt: principalDebt,
              onDeletePressed: canManageDebt
                  ? () => _confirmDebtDelete(context, principalDebt)
                  : null,
              onEditPressed: canManageDebt
                  ? () => setState(() => _isEditing = true)
                  : null,
              onViewDebtPressed: canManageDebt && _isOpenDebt(principalDebt)
                  ? () => _openDebtDetail(context, principalDebt, state)
                  : null,
            );
          },
        ),
      );
    }

    return BlocProvider(
      create: (context) => RecurringTransfertBloc(
        context.read<RecurringTransfertRepositoryImpl>(),
      ),
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listenWhen: (previous, current) =>
            current is TransactionDeleted ||
            (!_isEditing && current is TransactionError),
        listener: _onTransactionStateChanged,
        builder: (context, state) {
          if (_isEditing) {
            final editForm =
                TransactionTypes.isIncomeType(transactionDetail.type)
                ? IncomeForm(
                    user: widget.transaction.user,
                    friends: widget.transaction.friends,
                    initialTransaction: transactionDetail,
                    onCompleted: () => Navigator.of(context).maybePop(),
                  )
                : ExpenseForm(
                    user: widget.transaction.user,
                    friends: widget.transaction.friends,
                    initialTransaction: transactionDetail,
                    onCompleted: () => Navigator.of(context).maybePop(),
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.l10n.transactionEditTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                AppDimens.spacerMedium,
                editForm,
              ],
            );
          }

          final pendingSalaryOccurrence = _findPendingSalaryOccurrence(context);

          return TransactionDetailContent(
            transaction: widget.transaction,
            canManage: canManage,
            isLoading: state is TransactionLoading,
            debt: _relatedDebt,
            onDeletePressed: canManage
                ? () => confirmDelete(
                    context,
                    title: context.l10n.transactionDeleteConfirmTitle,
                    description:
                        context.l10n.transactionDeleteConfirmDescription,
                    onConfirm: () {
                      context.read<TransactionBloc>().add(
                        DeleteTransactionEvent(
                          widget.transaction.transactionDetail,
                        ),
                      );
                    },
                  )
                : null,
            onEditPressed:
                canManage &&
                    !_isDebtRepayment &&
                    transactionDetail.type !=
                        TransactionTypes.walletTransferCode
                ? () => setState(() => _isEditing = true)
                : null,
            onConfirmSalaryPressed: pendingSalaryOccurrence != null
                ? () => openOccurrenceSheet(context, pendingSalaryOccurrence)
                : null,
          );
        },
      ),
    );
  }
}
