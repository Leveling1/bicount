import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_plan_pause.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurringPlanPauseHistory extends StatelessWidget {
  const RecurringPlanPauseHistory({super.key, required this.pauses});

  final List<RecurringPlanPause> pauses;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    String label(String day) => formatter.format(DateTime.parse(day));

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recurringPlanPauseHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final pause in pauses.reversed) ...[
            AppDimens.spacerSmall,
            Text(l10n.recurringPlanPausedOn(label(pause.pausedOn))),
            if (pause.resumedOn case final day?)
              Text(l10n.recurringPlanResumedOn(label(day))),
            if (pause.nextDueDateOverride case final day?)
              Text(l10n.recurringPlanNewDueOn(label(day))),
          ],
        ],
      ),
    );
  }
}
