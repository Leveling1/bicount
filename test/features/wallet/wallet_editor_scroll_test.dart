import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor_preview.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final editing in [false, true]) {
    testWidgets(
      'title and preview stay fixed while wallet fields scroll, editing $editing',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        for (final size in [const Size(320, 640), const Size(400, 740)]) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showCustomBottomSheet<void>(
                      context: context,
                      minHeight: .95,
                      scrollEnabled: false,
                      horizontalPadding: 0,
                      child: WalletEditor(
                        wallet: editing
                            ? const WalletModel(
                                id: 'bank',
                                ownerUid: 'user',
                                name: 'Bank',
                                createdAt: '-',
                                kind: WalletKind.card,
                                cardNetwork: WalletCardNetwork.visa,
                              )
                            : null,
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          final title = find.byKey(const ValueKey('wallet-editor-title'));
          final preview = find.byType(WalletEditorPreview);
          final fields = find.byKey(const ValueKey('wallet-editor-fields'));
          final name = find.descendant(
            of: find.byType(CustomFormField),
            matching: find.byType(TextFormField),
          );
          final horizontalRows = find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.horizontal,
          );
          expect(horizontalRows, findsNWidgets(editing ? 2 : 1));
          for (final row in horizontalRows.evaluate()) {
            final bounds = tester.getRect(
              find.byElementPredicate((element) => identical(element, row)),
            );
            expect(bounds.left, 0);
            expect(bounds.right, size.width);
          }
          expect(tester.getTopLeft(name).dx, 25);
          final types = horizontalRows.first;
          await tester.ensureVisible(types);
          await tester.pump();
          final typeScroll = tester.state<ScrollableState>(
            find.descendant(of: types, matching: find.byType(Scrollable)),
          );
          await tester.dragFrom(
            Offset(size.width - 12, tester.getCenter(types).dy),
            const Offset(-100, 0),
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(typeScroll.position.pixels, greaterThan(0));
          for (final keyboard in [0.0, 260.0]) {
            tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
            await tester.pump();
            final scrollable = tester.state<ScrollableState>(
              find
                  .descendant(of: fields, matching: find.byType(Scrollable))
                  .first,
            );
            scrollable.position.jumpTo(0);
            await tester.pump();
            final titleBounds = tester.getRect(title);
            final previewBounds = tester.getRect(preview);
            final nameTop = tester.getTopLeft(name).dy;
            await tester.drag(fields, const Offset(0, -180));
            await tester.pump(const Duration(milliseconds: 400));
            expect(scrollable.position.pixels, greaterThan(0));
            expect(tester.getTopLeft(name).dy, lessThan(nameTop));
            expect(tester.getRect(title), titleBounds);
            expect(tester.getRect(preview), previewBounds);
            expect(tester.getSize(fields).height, greaterThan(70));
            expect(tester.takeException(), isNull);
          }
          await tester.ensureVisible(find.text('Save'));
          await tester.pump();
          expect(find.text('Save').hitTestable(), findsOneWidget);
          await tester.ensureVisible(name);
          await tester.enterText(name, 'Voyages');
          await tester.pump();
          expect(
            tester
                .widget<WalletCardFace>(find.byType(WalletCardFace))
                .wallet!
                .name,
            'Voyages',
          );
          expect(tester.takeException(), isNull);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          tester.view.resetViewInsets();
          await tester.pump();
        }
      },
    );
  }
}
