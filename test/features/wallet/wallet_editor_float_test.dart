import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor_preview.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'the level card floats subtly without a ground shadow or restarting edits',
    (tester) async {
      final name = TextEditingController(text: 'Ma carte');
      addTearDown(name.dispose);
      var reducedMotion = false;
      Future<void> pumpPreview() => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(disableAnimations: reducedMotion),
              child: Center(
                child: SizedBox(
                  width: 360,
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
      await pumpPreview();
      final face = find.byType(WalletCardFace);
      final start = tester.getTopLeft(face);
      final shadow = find.byKey(const ValueKey('wallet-preview-shadow'));
      expect(shadow, findsNothing);
      void expectLevel() {
        expect(
          tester.getTopRight(face).dy,
          closeTo(tester.getTopLeft(face).dy, .001),
        );
        expect(tester.getBottomLeft(face).dx, closeTo(start.dx, .001));
        expect(tester.getTopLeft(face).dx, closeTo(start.dx, .001));
      }

      expectLevel();
      await tester.pump(const Duration(seconds: 3));
      final midpoint = tester.getTopLeft(face);
      expect(midpoint.dy - start.dy, closeTo(2, .1));
      expectLevel();
      name.text = 'Voyages';
      await tester.pump();
      expect(tester.getTopLeft(face), midpoint);
      expect(tester.widget<WalletCardFace>(face).wallet!.name, 'Voyages');
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getTopLeft(face).dy - start.dy, closeTo(4, .01));
      expectLevel();
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getTopLeft(face).dy, closeTo(midpoint.dy, .01));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getTopLeft(face).dy, closeTo(start.dy, .01));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getTopLeft(face).dy, closeTo(midpoint.dy, .01));

      reducedMotion = true;
      await pumpPreview();
      final resting = tester.getTopLeft(face);
      await tester.pump(const Duration(seconds: 4));
      expect(tester.getTopLeft(face), resting);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
