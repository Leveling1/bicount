import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings fill stays on the whole row while the content scales', (
    tester,
  ) async {
    final theme = AppTheme.lightTheme;
    var profileTaps = 0;
    var contactsTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: SettingsSection(
                title: 'Account',
                children: [
                  SettingsActionTile(
                    icon: Icons.person_outline,
                    title: 'Edit profile',
                    subtitle: 'Update your profile',
                    onTap: () => profileTaps++,
                  ),
                  SettingsActionTile(
                    icon: Icons.people_outline,
                    title: 'Contacts',
                    subtitle: 'Manage your contacts',
                    onTap: () => contactsTaps++,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final card = tester.getRect(find.byType(DetailsCard));
    final row = find.byType(SettingsActionTile).first;
    final rowBounds = tester.getRect(row);
    final title = find.text('Edit profile');
    final titleSize = tester.getSize(title);
    final titleBounds = tester.getRect(title);
    final icon = find.byIcon(Icons.person_outline);
    expect(tester.getTopLeft(icon).dx - card.left, AppDimens.paddingMedium);
    expect(rowBounds.left, card.left);
    expect(rowBounds.right, card.right);
    expect(rowBounds.top, card.top);
    expect(
      tester.getRect(find.byType(SettingsActionTile).last).bottom,
      card.bottom,
    );

    final press = await tester.startGesture(
      Offset(card.left + AppDimens.paddingExtraSmall, rowBounds.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));

    final tint = appPressedColor(theme.primaryColor);
    final fill = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is ShapeDecoration &&
          (widget.decoration as ShapeDecoration).color == tint,
    );
    expect(fill, findsOneWidget);
    expect(tester.getRect(fill), rowBounds);
    expect(tester.getRect(title).width, lessThan(titleBounds.width));
    expect(tester.getSize(title), titleSize);
    expect(profileTaps, 0);
    expect(contactsTaps, 0);
    await press.up();
    await tester.pumpAndSettle();
    expect(profileTaps, 1);
    expect(contactsTaps, 0);
    expect(fill, findsNothing);
    expect(tester.getRect(title), titleBounds);
  });
}
