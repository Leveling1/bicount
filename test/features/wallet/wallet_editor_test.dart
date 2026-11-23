import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
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
            body: SingleChildScrollView(
              child: WalletEditor(
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
        ),
      );
      final field = find.descendant(
        of: find.byType(CustomFormField),
        matching: find.byType(TextFormField),
      );
      final controller = tester.widget<TextFormField>(field).controller!;
      final form = tester.state<FormState>(find.byType(Form));
      expect(controller.text, editing ? 'Bank' : '');

      await tester.enterText(field, '   ');
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);

      final longName = List.filled(61, 'é').join();
      await tester.enterText(field, longName);
      expect(controller.text.characters.length, 60);
      expect(form.validate(), isTrue);
      await tester.pump();
      expect(find.text('This field is required'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
