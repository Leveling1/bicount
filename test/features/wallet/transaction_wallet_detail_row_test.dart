import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/transaction_wallet_detail_row.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'wallet details menu follows the trailing edge and stays on screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const current = WalletModel(
        id: 'current',
        ownerUid: 'owner',
        name: 'Main',
        createdAt: '',
      );
      const other = WalletModel(
        id: 'other',
        ownerUid: 'owner',
        name: 'Orange',
        createdAt: '',
      );
      const rowKey = ValueKey('wallet row');

      for (final direction in TextDirection.values) {
        for (final nearBottom in [false, true]) {
          String? selection;
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Stack(
                    children: [
                      Positioned(
                        left: 32,
                        right: 32,
                        top: nearBottom ? 440 : 128,
                        child: TransactionWalletDetailRow(
                          key: rowKey,
                          title: 'Wallet',
                          wallet: current,
                          options: const [current, other],
                          onChanged: (walletId) => selection = walletId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          final row = tester.getRect(find.byKey(rowKey));
          await tester.tap(find.text(current.name));
          await tester.pumpAndSettle();
          final menu = find
              .ancestor(
                of: find.text(other.name),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Material &&
                      widget.clipBehavior == Clip.antiAlias,
                ),
              )
              .first;
          final bounds = tester.getRect(menu);
          final shape =
              tester.widget<Material>(menu).shape as RoundedRectangleBorder;
          expect(
            shape.borderRadius,
            const BorderRadius.all(Radius.circular(12)),
          );
          if (direction == TextDirection.ltr) {
            expect(bounds.right, closeTo(row.right, .1));
          } else {
            expect(bounds.left, closeTo(row.left, .1));
          }
          if (nearBottom) {
            expect(bounds.bottom, lessThanOrEqualTo(row.top));
          } else {
            expect(bounds.top, greaterThanOrEqualTo(row.bottom));
          }

          await tester.tap(find.text(other.name));
          await tester.pumpAndSettle();
          expect(selection, other.id);
        }
      }
    },
  );
}
