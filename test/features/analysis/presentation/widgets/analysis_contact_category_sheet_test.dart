import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_contact_category_sheet.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects multiple contacts with the other chart off by default', (
    tester,
  ) async {
    final saved = <({Set<String> contacts, bool bothCharts})>[];
    final friends = [
      for (final name in ['Alice', 'Bob'])
        FriendsModel(
          sid: name,
          fid: 'owner',
          username: name,
          email: '',
          image: '',
          relationType: FriendConst.friend,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showCustomBottomSheet<void>(
                context: context,
                minHeight: 0,
                scrollEnabled: false,
                child: AnalysisContactCategorySheet(
                  chart: AnalysisChart.income,
                  selection: (
                    ownerUid: 'owner',
                    contacts: friends,
                    selected: <String>{},
                  ),
                  onSave: (contacts, bothCharts) async {
                    saved.add((contacts: contacts, bothCharts: bothCharts));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final bothCharts in [false, true]) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      final toggle = find.byType(SwitchListTile);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      final search = find.byType(CustomSearchField);
      expect(search, findsOneWidget);
      await tester.enterText(
        find.descendant(of: search, matching: find.byType(TextField)),
        'alice',
      );
      await tester.pumpAndSettle();
      expect(find.text('Bob'), findsNothing);
      await tester.tap(find.text('Alice'));
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Bob'), findsOneWidget);
      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      if (bothCharts) {
        await tester.tap(toggle);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();
      expect(saved.last.contacts, {'Alice', 'Bob'});
      expect(saved.last.bothCharts, bothCharts);
      expect(find.byType(BottomSheet), findsNothing);
    }
  });
}
