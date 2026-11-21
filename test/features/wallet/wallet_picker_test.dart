import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'the shared wallet menu keeps its default and returns a wallet ID',
    (tester) async {
      const principal = WalletModel(
        id: 'principal',
        ownerUid: 'user',
        name: 'Principal',
        createdAt: '',
        isDefault: true,
      );
      const bank = WalletModel(
        id: 'bank',
        ownerUid: 'user',
        name: 'Bank',
        createdAt: '',
      );
      const archived = WalletModel(
        id: 'archived',
        ownerUid: 'user',
        name: 'Archived wallet',
        createdAt: '',
        archivedAt: '2026-11-15',
      );
      final form = GlobalKey<FormState>();
      String? selectedId;
      Future<void> pumpWallets(List<WalletModel> wallets) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Form(
              key: form,
              child: WalletDropdown(
                label: 'Pay from',
                useSharedMenu: true,
                wallets: wallets,
                onChanged: (id) => selectedId = id,
              ),
            ),
          ),
        ),
      );

      await pumpWallets([]);
      expect(form.currentState!.validate(), isTrue);
      await pumpWallets([principal, archived, bank]);
      expect(find.byType(CustomDropdownMenu), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Main wallet',
      );
      expect(selectedId, isNull);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Archived wallet').hitTestable(), findsNothing);
      await tester.tap(find.text('Bank').hitTestable());
      await tester.pumpAndSettle();
      expect(selectedId, 'bank');
      expect(form.currentState!.validate(), isTrue);
    },
  );
}
