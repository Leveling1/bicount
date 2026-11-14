import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_transition.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'the bottom bar releases its space while the keyboard is visible',
    (tester) async {
      const bodyKey = Key('transaction body');
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeWalletTransition(
            hasSharedContainer: true,
            enabled: false,
            selectedIndex: 2,
            onSelectTab: (_) {},
            onSelectCoveredTab: (_) {},
            builder: (_) => const Scaffold(body: SizedBox.expand(key: bodyKey)),
          ),
        ),
      );

      final navigation = find.byType(CustomBottomNavigationBar);
      final body = find.byKey(bodyKey);
      final originalBottom = tester.getBottomLeft(body).dy;
      expect(navigation, findsOneWidget);

      const keyboardHeight = 300.0;
      tester.view.viewInsets = FakeViewPadding(
        bottom: keyboardHeight * tester.view.devicePixelRatio,
      );
      await tester.pumpAndSettle();
      expect(navigation, findsNothing);
      final keyboardTop =
          tester.view.physicalSize.height / tester.view.devicePixelRatio -
          keyboardHeight;
      expect(keyboardTop - tester.getBottomLeft(body).dy, 4);

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(navigation, findsOneWidget);
      expect(tester.getBottomLeft(body).dy, originalBottom);
    },
  );

  testWidgets(
    'an adjacent tab keeps the active PageView while selection changes',
    (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      var index = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatefulBuilder(
            builder: (context, setState) => HomeWalletTransition(
              hasSharedContainer: true,
              enabled: index == 0,
              selectedIndex: index,
              onSelectCoveredTab: (_) {},
              onSelectTab: (target) {
                controller.animateToPage(
                  target,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                );
                setState(() => index = target);
              },
              builder: (_) => Scaffold(
                body: PageView(
                  controller: controller,
                  physics: index == 0
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  children: const [
                    Text('Home content'),
                    Text('Analysis content'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final page = tester.element(find.byType(PageView));
      final clip = tester.element(find.byType(ContainerBody));
      await tester.tap(find.text('Analysis'));
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(PageView)), same(page));
      expect(tester.element(find.byType(ContainerBody)), same(clip));
      expect(controller.page, 1);
      expect(find.text('Analysis content').hitTestable(), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(controller.page, 0);
      expect(find.text('Home content').hitTestable(), findsOneWidget);
    },
  );
}
