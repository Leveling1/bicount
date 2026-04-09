import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/search/subscription_search_delegate.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_detail_sheet.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_screen_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: context.l10n.graphSubscriptions,
            actions: [
              if (state is MainLoaded && false) // subscriptions removed
                IconButton(
                  onPressed: () => _openSearch(context, state.startData),
                  icon: const Icon(Icons.search_rounded),
                ),
            ],
          ),
          body: switch (state) {
            MainLoaded() => SubscriptionScreenContent(
              data: state.startData,
              onTap: (item) => showSubscriptionDetailSheet(context, item),
            ),
            MainError() => _SubscriptionErrorState(
              onRetry: () => context.read<MainBloc>().add(GetAllStartData()),
            ),
            _ => const SubscriptionLoadingView(),
          },
        );
      },
    );
  }

  Future<void> _openSearch(BuildContext context, MainEntity data) async {
    final result = await showSearch<SubscriptionListItem?>(
      context: context,
      delegate: SubscriptionSearchDelegate(
        items: buildSubscriptionListItems(data),
        searchFieldText: context.l10n.commonSearch,
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    await showSubscriptionDetailSheet(context, result);
  }
}

class _SubscriptionErrorState extends StatelessWidget {
  const _SubscriptionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_tethering_error_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.runtimeDataLoadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
