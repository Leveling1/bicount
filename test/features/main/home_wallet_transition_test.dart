import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_flight.dart';
import 'package:bicount/features/home/presentation/widgets/home_wallet_preview.dart';
import 'package:bicount/features/main/domain/repositories/main_repository.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_cards.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_transition.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

part 'home_wallet_transition_fixtures.dart';

void main() {
  const home = Key('home body');
  const preview = Key('wallet preview');

  testWidgets(
    'three shared cards follow an opening drag and reverse on return',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(410, 860);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final selectedTab = ValueNotifier(0);
      addTearDown(selectedTab.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => MainBloc(_MainRepository())),
              BlocProvider(
                create: (_) =>
                    WalletBloc(_WalletRepository())..add(const WatchWallets()),
              ),
            ],
            child: ValueListenableBuilder(
              valueListenable: selectedTab,
              builder: (context, index, _) => HomeWalletTransition(
                enabled: index == 0,
                hasSharedContainer: true,
                selectedIndex: index,
                onSelectTab: (_) {},
                onSelectCoveredTab: (tab) => selectedTab.value = tab,
                builder: (openWallets) => Scaffold(
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        key: home,
                        child: Text(
                          index == 0 ? 'Dashboard' : 'Analysis content',
                        ),
                      ),
                      Positioned(
                        top: 130,
                        right: 0,
                        width: HomeWalletPreview.width,
                        height: 170,
                        child: HomeWalletPreview(
                          key: preview,
                          onOpen: openWallets,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      final container = find.byType(ContainerBody);
      expect(container, findsOneWidget);
      final sharedClip = find
          .descendant(of: container, matching: find.byType(ClipRRect))
          .first;
      final clipBounds = tester.getRect(sharedClip);
      expect(
        tester.widget<ClipRRect>(sharedClip).borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(50)),
      );

      await tester.tapAt(const Offset(150, 480));
      await tester.pumpAndSettle();
      expect(find.text('New wallet'), findsNothing);

      final previewContext = tester.element(find.byKey(preview));
      final geometry = WalletCardFlight.maybeOf(previewContext)!.geometry;
      final origin = geometry.bounds(WalletCardEndpoint.preview, 'main');

      final drag = await tester.startGesture(const Offset(370, 500));
      await drag.moveBy(const Offset(-35, 0));
      await tester.pump();
      await drag.moveBy(const Offset(-190, 0));
      await tester.pump();

      final flight = tester.widget<HomeWalletCards>(
        find.byType(HomeWalletCards),
      );
      expect(flight.progress, inExclusiveRange(0, 1));
      expect(tester.getRect(sharedClip), clipBounds);
      expect(
        find.descendant(of: container, matching: find.byType(WalletScreen)),
        findsOneWidget,
      );
      expect(flight.paths, hasLength(3));
      expect(flight.paths.first.preview, origin);
      final endpointContext = geometry
          .anchor(WalletCardEndpoint.list, 'main')
          .currentContext!;
      expect(
        WalletCardFlight.maybeOf(endpointContext)!.movingIds,
        hasLength(3),
      );
      expect(
        flight.paths.last.destination.top,
        greaterThan(flight.paths.first.destination.top),
      );
      expect(tester.getTopLeft(find.byKey(home)).dx, lessThan(0));

      await drag.up();
      await tester.pumpAndSettle();
      expect(find.byType(HomeWalletCards), findsNothing);
      expect(tester.getRect(sharedClip), clipBounds);
      expect(find.text('New wallet').hitTestable(), findsOneWidget);
      final navigation = find.byType(CustomBottomNavigationBar);
      expect(
        tester.widget<CustomBottomNavigationBar>(navigation).selectedIndex,
        0,
      );

      await tester.dragFrom(const Offset(40, 550), const Offset(320, 0));
      await tester.pumpAndSettle();
      expect(find.text('New wallet'), findsNothing);
      expect(tester.getTopLeft(find.byKey(home)).dx, 0);

      final shortDrag = await tester.startGesture(const Offset(300, 480));
      await shortDrag.moveBy(const Offset(-55, 0));
      await tester.pump(const Duration(milliseconds: 250));
      await shortDrag.up();
      await tester.pumpAndSettle();
      expect(find.text('New wallet'), findsNothing);

      await tester.tap(find.byKey(preview));
      await tester.pumpAndSettle();
      expect(find.text('New wallet').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('New wallet'), findsNothing);
      await tester.tap(find.byKey(preview));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Analysis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(selectedTab.value, 1);
      expect(find.text('Analysis content'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.byType(WalletScreen), findsOneWidget);
      expect(find.byType(HomeWalletCards), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(WalletScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
