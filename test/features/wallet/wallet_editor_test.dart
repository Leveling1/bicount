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
    testWidgets('wallet name validation and length, editing $editing', (
      tester,
    ) async {
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
                      createdAt: '2026-11-21',
                    )
                  : null,
            ),
          ),
        ),
      );
      final field = find.descendant(
        of: find.byType(CustomFormField),
        matching: find.byType(TextFormField),
      );
      final controller = tester.widget<TextFormField>(field).controller!;
      final preview = find.byType(WalletEditorPreview);
      WalletModel draft() => tester
          .widget<WalletCardFace>(
            find.descendant(of: preview, matching: find.byType(WalletCardFace)),
          )
          .wallet!;
      expect(
        tester.getBottomLeft(preview).dy,
        lessThan(tester.getTopLeft(field).dy),
      );
      expect(draft().name, editing ? 'Bank' : 'Wallet name');
      await tester.enterText(field, 'Mon voyage');
      await tester.pump();
      expect(draft().name, 'Mon voyage');
      final form = tester.state<FormState>(find.byType(Form));

      await tester.enterText(field, '   ');
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(draft().name, 'Wallet name');
      expect(find.text('This field is required'), findsOneWidget);

      final longName = List.filled(61, 'é').join();
      await tester.enterText(field, longName);
      expect(controller.text.characters.length, 60);
      expect(form.validate(), isTrue);
      await tester.pump();
      expect(draft().name.characters.length, 60);
      expect(find.text('This field is required'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
