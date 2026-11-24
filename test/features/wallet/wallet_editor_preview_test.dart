import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor_preview.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  for (final editing in [false, true]) {
    testWidgets(
      'live preview follows type, network, operator and color, editing $editing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: WalletEditor(
                wallet: editing
                    ? const WalletModel(
                        id: 'bank',
                        ownerUid: 'user',
                        name: 'Bank',
                        createdAt: '-',
                        kind: WalletKind.bankAccount,
                        icon: 2,
                        color: 3,
                      )
                    : null,
              ),
            ),
          ),
        );
        final preview = find.byType(WalletEditorPreview);
        WalletModel draft() => tester
            .widget<WalletCardFace>(
              find.descendant(
                of: preview,
                matching: find.byType(WalletCardFace),
              ),
            )
            .wallet!;
        expect(
          draft().kind,
          editing ? WalletKind.bankAccount : WalletKind.other,
        );
        expect(draft().color, editing ? 3 : 0);
        final l10n = AppLocalizations.of(tester.element(preview))!;
        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pump();
        }

        Finder svg(String asset) => find.descendant(
          of: preview,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SvgPicture &&
                widget.bytesLoader is SvgAssetLoader &&
                (widget.bytesLoader as SvgAssetLoader).assetName ==
                    'assets/icons/$asset.svg',
          ),
        );

        await tap(find.text(l10n.walletCard));
        expect(draft().kind, WalletKind.card);
        expect(draft().icon, WalletKind.card.legacyIcon);
        expect(svg('credit_card'), findsOneWidget);
        final palette = find.byTooltip(l10n.walletColorGold);
        final closedTop = tester.getTopLeft(palette).dy;
        await tester.pump(const Duration(milliseconds: 120));
        final openingTop = tester.getTopLeft(palette).dy;
        await tester.pump(const Duration(milliseconds: 140));
        expect(openingTop, greaterThan(closedTop));
        expect(tester.getTopLeft(palette).dy, greaterThan(openingTop));

        await tap(find.text('Visa'));
        expect(draft().cardNetwork, WalletCardNetwork.visa);
        expect(svg('visa'), findsOneWidget);
        final face = find.descendant(
          of: preview,
          matching: find.byType(WalletCardFace),
        );
        final cardBounds = tester.getRect(face);
        final logoBounds = tester.getRect(svg('visa'));
        expect(
          cardBounds.right - logoBounds.right,
          closeTo(cardBounds.width * .05, .01),
        );
        expect(
          cardBounds.bottom - logoBounds.bottom,
          closeTo(cardBounds.width * .05, .01),
        );

        await tap(find.byTooltip(l10n.walletColorGold));
        expect(draft().color, 4);

        await tap(find.text(l10n.walletMobile));
        expect(draft().kind, WalletKind.mobileMoney);
        expect(draft().cardNetwork, isNull);
        expect(svg('visa'), findsNothing);
        expect(svg('phone'), findsOneWidget);
        expect(draft().mobileOperator, isNull);
        expect(find.text('Visa').hitTestable(), findsNothing);
        await tester.pump(const Duration(milliseconds: 260));
        for (final (label, operator) in [
          ('M-Pesa', WalletMobileOperator.mpesa),
          ('Orange Money', WalletMobileOperator.orangeMoney),
          ('Airtel Money', WalletMobileOperator.airtelMoney),
          ('Afrimoney', WalletMobileOperator.afrimoney),
        ]) {
          await tap(find.text(label));
          expect(draft().mobileOperator, operator);
          expect(svg(operator.code), findsOneWidget);
        }
        await tap(find.text(l10n.walletNoProvider));
        expect(draft().mobileOperator, isNull);
        expect(svg('afrimoney'), findsNothing);

        await tap(find.text(l10n.walletCash));
        expect(draft().kind, WalletKind.cash);
        expect(svg('piggy_bank'), findsOneWidget);
        final openTop = tester.getTopLeft(palette).dy;
        await tester.pump(const Duration(milliseconds: 120));
        final closingTop = tester.getTopLeft(palette).dy;
        await tester.pump(const Duration(milliseconds: 140));
        expect(closingTop, lessThan(openTop));
        expect(tester.getTopLeft(palette).dy, lessThan(closingTop));
        expect(find.text(l10n.walletMobileOperator), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('floating preview fits small screens, themes and enlarged text', (
    tester,
  ) async {
    final name = TextEditingController(
      text: 'Mon portefeuille pour les vacances',
    );
    addTearDown(name.dispose);
    for (final width in [240.0, 360.0]) {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: WalletEditorPreview(
                      name: name,
                      kind: WalletKind.card,
                      network: WalletCardNetwork.visa,
                      color: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final bounds = tester.getRect(find.byType(WalletEditorPreview));
        final card = tester.renderObject<RenderBox>(
          find.byType(WalletCardFace),
        );
        for (final point in [
          Offset.zero,
          Offset(card.size.width, 0),
          Offset(0, card.size.height),
          Offset(card.size.width, card.size.height),
        ]) {
          expect(bounds.contains(card.localToGlobal(point)), isTrue);
        }
        expect(tester.takeException(), isNull);
      }
    }
  });
}
