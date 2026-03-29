import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_item_list.dart';
import 'package:flutter/material.dart';

class SubscriptionSearchDelegate extends SearchDelegate<SubscriptionListItem?> {
  SubscriptionSearchDelegate({
    required this.items,
    required this.searchFieldText,
  }) : super(searchFieldLabel: searchFieldText);

  final List<SubscriptionListItem> items;
  final String searchFieldText;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SubscriptionSearchBody(
      items: filterSubscriptionListItems(items, query),
      query: query,
      onTap: (item) => close(context, item),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SubscriptionSearchBody(
      items: filterSubscriptionListItems(items, query),
      query: query,
      onTap: (item) => close(context, item),
    );
  }
}

class _SubscriptionSearchBody extends StatelessWidget {
  const _SubscriptionSearchBody({
    required this.items,
    required this.query,
    required this.onTap,
  });

  final List<SubscriptionListItem> items;
  final String query;
  final ValueChanged<SubscriptionListItem> onTap;

  @override
  Widget build(BuildContext context) {
    final emptyMessage = query.trim().isEmpty
        ? context.l10n.subscriptionSearchPrompt
        : context.l10n.subscriptionSearchEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingMedium,
        AppDimens.paddingExtraLarge,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        SubscriptionItemList(
          items: items,
          onTap: onTap,
          emptyMessage: emptyMessage,
        ),
      ],
    );
  }
}
