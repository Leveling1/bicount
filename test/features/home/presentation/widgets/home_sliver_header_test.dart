import 'package:bicount/features/home/presentation/widgets/card_type_revenue.dart';
import 'package:bicount/features/home/presentation/widgets/home_header_sliver_layout.dart';
import 'package:bicount/features/home/presentation/widgets/home_sliver_header.dart';
import 'package:bicount/features/home/presentation/widgets/home_summary_card.dart';
import 'package:bicount/features/home/presentation/widgets/home_wallet_preview.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final withWallet in [false, true]) {
    testWidgets(
      'the responsive Home header keeps a 16 dp gap, wallets $withWallet',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);
        const salaryCard = Key('salary card');
        double? previousHeight;
        for (final config in [
          (width: 390.0, scale: 1.0, language: 'en'),
          (width: 320.0, scale: 1.0, language: 'fr'),
          (width: 320.0, scale: 1.8, language: 'fr'),
          (width: 700.0, scale: 1.0, language: 'en'),
        ]) {
          if (controller.hasClients) controller.jumpTo(0);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(config.language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BlocProvider(
                create: (_) =>
                    WalletBloc(_WalletRepository())..add(const WatchWallets()),
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(config.scale),
                  ),
                  child: Scaffold(
                    body: Center(
                      child: SizedBox(
                        width: config.width,
                        height: 560,
                        child: CustomScrollView(
                          controller: controller,
                          slivers: [
                            HomeSliverHeader(
                              balance: 950,
                              referenceCurrencyCode: 'CDF',
                              monthlyInflow: 1300,
                              monthlyOutflow: 350,
                              incomeColor: Colors.green,
                              expenseColor: Colors.red,
                              onOpenWallets: withWallet ? () {} : null,
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(key: salaryCard, height: 72),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));

          final summary = find.byType(HomeSummaryCard);
          final initialSize = tester.getSize(summary);
          final header = tester.renderObject<RenderSliver>(
            find.byType(HomeHeaderSliverLayout),
          );
          expect(header.geometry!.scrollExtent, initialSize.height);
          final lastContent = withWallet
              ? find.byType(HomeWalletPreview)
              : find.byType(CardTypeRevenue).last;
          expect(
            tester.getTopLeft(find.byKey(salaryCard)).dy -
                tester.getBottomLeft(lastContent).dy,
            closeTo(16, .01),
          );
          if (config.scale > 1) {
            expect(initialSize.height, greaterThan(previousHeight!));
          }
          previousHeight = initialSize.height;

          final distance =
              header.geometry!.scrollExtent -
              header.geometry!.maxScrollObstructionExtent;
          controller.jumpTo(distance * .29);
          await tester.pump();
          expect(tester.getSize(summary), initialSize);
          final fades = tester.layers.whereType<OpacityLayer>().where(
            (layer) =>
                layer.alpha != null && layer.alpha! > 0 && layer.alpha! < 255,
          );
          expect(fades.length, greaterThanOrEqualTo(2));
          controller.jumpTo(distance + 50);
          await tester.pump();
          expect(tester.getSize(summary), initialSize);
          expect(
            header.geometry!.paintExtent,
            header.geometry!.maxScrollObstructionExtent,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}

class _WalletRepository implements WalletRepository {
  @override
  Stream<List<WalletModel>> watch() => Stream.value(const [
    WalletModel(
      id: 'principal',
      ownerUid: 'user',
      name: 'Principal',
      createdAt: '',
      isDefault: true,
    ),
  ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
