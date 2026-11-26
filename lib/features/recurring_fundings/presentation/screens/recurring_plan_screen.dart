import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_tool_tip.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_pause_action.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_sheet.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_pause_sheet.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_screen_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        final collection = state is MainLoaded
            ? _builder.build(
                recurringTransferts: state.startData.recurringTransferts,
                transactions: state.startData.transactions,
                currencyConfig: currencyConfig,
                scope: scope,
              )
            : null;
        return Scaffold(
          appBar: CustomAppBar(
            title: _title(context),
            leading: _buildBackButton(context),
            actions: _actions(context, collection?.plans ?? const []),
            automaticallyImplyLeading: false,
          ),
          body: switch (state) {
            MainLoaded() => RecurringPlanScreenContent(
              scope: scope,
              data: state.startData,
              referenceCurrencyCode: state.startData.referenceCurrencyCode,
              collection: collection!,
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

  Widget _buildBackButton(BuildContext context) {
    return BackButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        context.go('/');
      },
    );
  }

  String _title(BuildContext context) {
    return switch (scope) {
      RecurringPlanScope.charge => context.l10n.recurringChargesTitle,
      RecurringPlanScope.income => context.l10n.recurringIncomesTitle,
    };
  }

  List<Widget> _actions(
    BuildContext context,
    List<RecurringPlanSummaryEntity> plans,
  ) {
    final active = plans.where((plan) => plan.isActive).toList();
    final paused = plans.where((plan) => plan.canResume).toList();
    return [
      if (active.isNotEmpty || paused.isNotEmpty)
        PopupMenuButton<RecurringPlanPauseAction>(
          tooltip: context.l10n.recurringPlansManagePauses,
          icon: const Icon(Icons.checklist_rounded),
          onSelected: (action) => showRecurringPlanPauseSheet(
            context,
            action: action,
            plans: action == RecurringPlanPauseAction.pause ? active : paused,
            bulk: true,
          ),
          itemBuilder: (context) => [
            if (active.isNotEmpty)
              PopupMenuItem(
                value: RecurringPlanPauseAction.pause,
                child: Text(context.l10n.recurringPlansPauseCta),
              ),
            if (paused.isNotEmpty)
              PopupMenuItem(
                value: RecurringPlanPauseAction.resume,
                child: Text(context.l10n.recurringPlansResumeCta),
              ),
          ],
        ),
      CustomToolTip(
        text: scope == RecurringPlanScope.charge
            ? context.l10n.recurringChargesIntro
            : context.l10n.recurringIncomesIntro,
        child: Icon(Icons.info_outlined),
      ),
    ];
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
