import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/pinned_header_delegate.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_expense_breakdown_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_income_breakdown_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_period_selector.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_budget_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_calendar.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_summary_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_screen_skeleton.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_wallet_distribution_card.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/analysis_metric_overview.dart';

part 'analysis_screen_content.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      buildWhen: (previous, current) {
        final previousHasDashboard = previous.dashboard != null;
        final currentHasDashboard = current.dashboard != null;
        if (previousHasDashboard != currentHasDashboard) {
          return true;
        }
        if (!currentHasDashboard) {
          return previous.status != current.status ||
              previous.errorMessage != current.errorMessage;
        }
        return false;
      },
      builder: (context, state) {
        if (state.status == AnalysisStatus.loading && state.dashboard == null) {
          return const AnalysisScreenSkeleton();
        }

        if (state.status == AnalysisStatus.failure && state.dashboard == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Text(
                state.errorMessage ?? context.l10n.analysisUnableToLoad,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final dashboard = state.dashboard;
        if (dashboard == null) {
          return const SizedBox.shrink();
        }

        return const _AnalysisScreenContent();
      },
    );
  }
}
