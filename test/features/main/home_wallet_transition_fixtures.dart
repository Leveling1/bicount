part of 'home_wallet_transition_test.dart';

class _MainRepository implements MainRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletRepository implements WalletRepository {
  @override
  Stream<List<WalletModel>> watch() => Stream.value(const [
    WalletModel(
      id: 'main',
      ownerUid: 'user',
      name: 'Principal',
      createdAt: '-',
      isDefault: true,
    ),
    WalletModel(
      id: 'bank',
      ownerUid: 'user',
      name: 'Bank',
      createdAt: '-',
      color: 2,
    ),
    WalletModel(
      id: 'cash',
      ownerUid: 'user',
      name: 'Cash',
      createdAt: '-',
      color: 4,
    ),
  ]);

  @override
  Future<List<WalletBalance>> balances() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _verifyWalletEditorSheets(WidgetTester tester) async {
  await tester.tap(find.text('New wallet').hitTestable());
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsOneWidget);
  expect(find.byType(AlertDialog), findsNothing);
  final save = find.text('Save');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
  expect(
    find.text(
      AppLocalizations.of(tester.element(save))!.validationFieldRequired,
    ),
    findsOneWidget,
  );
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsNothing);

  final edit = find.descendant(
    of: find.byKey(const ValueKey('bank')),
    matching: find.byTooltip('Edit wallet'),
  );
  await tester.ensureVisible(edit);
  await tester.tap(edit);
  await tester.pumpAndSettle();
  final sheet = find.byType(BottomSheet);
  expect(sheet, findsOneWidget);
  expect(find.byType(AlertDialog), findsNothing);
  expect(
    find.descendant(of: sheet, matching: find.text('Edit wallet')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: sheet, matching: find.text('Bank')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: sheet, matching: find.text('Archive wallet')),
    findsOneWidget,
  );
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(sheet, findsNothing);
}
