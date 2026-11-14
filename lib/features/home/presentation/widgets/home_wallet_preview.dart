import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_flight.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeWalletPreview extends StatelessWidget {
  const HomeWalletPreview({super.key, required this.onOpen});

  static const double width = 74;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final flight = WalletCardFlight.maybeOf(context);
    final wallets = context.select((WalletBloc bloc) => bloc.state.wallets);
    final preview = <WalletModel?>[
      ...wallets.where((wallet) => wallet.archivedAt == null).take(3),
    ];
    if (preview.isEmpty) preview.add(null);
    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: context.l10n.walletTitle,
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                children: [
                  for (final (index, wallet) in preview.indexed)
                    PositionedDirectional(
                      start: index * 14.0,
                      top: 0,
                      bottom: 0,
                      width: constraints.maxHeight * WalletCardFace.aspectRatio,
                      child: SizedBox.expand(
                        key: wallet == null
                            ? null
                            : flight?.geometry.anchor(
                                WalletCardEndpoint.preview,
                                wallet.id,
                              ),
                        child: flight?.movingIds.contains(wallet?.id) == true
                            ? null
                            : WalletCardFace(
                                wallet: wallet,
                                showDetails: false,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
