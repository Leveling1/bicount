import 'package:bicount/features/whats_new/domain/repositories/whats_new_repository.dart';
import 'package:bicount/features/whats_new/presentation/whats_new_release.dart';
import 'package:bicount/features/whats_new/presentation/widgets/whats_new_dialog.dart';
import 'package:bicount/features/whats_new/presentation/widgets/whats_new_prompt.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waits for the home screen and an announcement', (tester) async {
    final repository = _MemoryRepository();
    await _open(tester, repository);
    expect(find.byType(WhatsNewDialog), findsNothing);

    await _open(tester, repository, release: _release('first'), enabled: false);
    expect(find.byType(WhatsNewDialog), findsNothing);

    await _open(tester, repository, release: _release('first'));
    expect(find.text('What’s new in Bicount'), findsOneWidget);
    expect(repository.dismissed, isEmpty);
  });

  testWidgets('dismisses once per release across app restarts', (tester) async {
    final repository = _MemoryRepository();
    await _open(tester, repository, release: _release('first'));
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(repository.dismissed, {'first'});

    await tester.pumpWidget(const SizedBox.shrink());
    await _open(tester, repository, release: _release('first'));
    expect(find.byType(WhatsNewDialog), findsNothing);

    await _open(tester, repository, release: _release('second'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(repository.dismissed, {'first', 'second'});
  });

  testWidgets('shows French on a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final repository = _MemoryRepository();
    await _open(
      tester,
      repository,
      release: _release('first', entryCount: 3),
      locale: const Locale('fr'),
    );
    expect(find.text('Nouveautés de Bicount'), findsOneWidget);
    await tester.tap(find.text('C’est compris'));
    await tester.pumpAndSettle();
    expect(repository.dismissed, {'first'});
    expect(tester.takeException(), isNull);
  });
}

WhatsNewRelease _release(String id, {int entryCount = 1}) => WhatsNewRelease(
  id: id,
  localizedEntries: (_) => List.filled(
    entryCount,
    const WhatsNewEntry(
      title: 'Détail de la mise à jour',
      description: 'Un exemple de description sur plusieurs lignes.',
    ),
  ),
);

Future<void> _open(
  WidgetTester tester,
  _MemoryRepository repository, {
  WhatsNewRelease? release,
  bool enabled = true,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WhatsNewPrompt(
        enabled: enabled,
        release: release,
        repository: repository,
        child: const Scaffold(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MemoryRepository implements WhatsNewRepository {
  final dismissed = <String>{};

  @override
  Future<bool> wasDismissed(String releaseId) async =>
      dismissed.contains(releaseId);

  @override
  Future<void> markDismissed(String releaseId) async {
    dismissed.add(releaseId);
  }
}
