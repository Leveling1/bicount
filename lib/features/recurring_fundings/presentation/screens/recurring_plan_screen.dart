import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_sheet.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_screen_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringPlanScreen extends StatelessWidget {
  const RecurringPlanScreen({super.key, required this.scope});

  final RecurringPlanScope scope;
  static const RecurringPlanCollectionBuilder _builder =
      RecurringPlanCollectionBuilder();

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;

    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: _title(context)),
          body: switch (state) {
            MainLoaded() => RecurringPlanScreenContent(
              scope: scope,
              data: state.startData,
              referenceCurrencyCode: state.startData.referenceCurrencyCode,
              collection: _builder.build(
                recurringTransferts: state.startData.recurringTransferts,
                transactions: state.startData.transactions,
                currencyConfig: currencyConfig,
                scope: scope,
              ),
              onTap: (summary) => showRecurringPlanDetailSheet(
                context,
                scope: scope,
                recurringTransfertId:
                    summary.recurringTransfert.recurringTransfertId ?? '',
              ),
            ),
            MainError() => _RecurringPlanErrorState(
              onRetry: () => context.read<MainBloc>().add(GetAllStartData()),
            ),
            _ => const RecurringPlanLoadingView(),
          },
        );
      },
    );
  }

  String _title(BuildContext context) {
    return switch (scope) {
      RecurringPlanScope.charge => context.l10n.recurringChargesTitle,
      RecurringPlanScope.income => context.l10n.recurringIncomesTitle,
    };
  }
}

class _RecurringPlanErrorState extends StatelessWidget {
  const _RecurringPlanErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onRetry,
        child: Text(context.l10n.commonRetry),
      ),
    );
  }
}
