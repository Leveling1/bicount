import 'package:bicount/features/wallet/data/models/wallet_model.dart';

typedef WalletBalance = ({String walletId, String currency, int minor});

const walletAmountScale = 100;

abstract interface class WalletRepository {
  Stream<List<WalletModel>> watch();
  Future<List<WalletBalance>> balances();
  Future<void> assignTransaction({
    required String tid,
    required bool isSender,
    required String walletId,
  });
  Future<void> save({
    WalletModel? existing,
    required String name,
    required WalletKind kind,
    WalletCardNetwork? network,
    required int icon,
    required int color,
    bool archived = false,
  });
  Future<void> transfer({
    required WalletModel from,
    required WalletModel to,
    required double amount,
    required String currency,
    required String title,
  });
}
