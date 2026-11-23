import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/wallet/domain/services/wallet_balance_total.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = CurrencyConfigEntity(
    referenceCurrencyCode: 'CDF',
    currencies: [],
    snapshotsByKey: {
      'old': ExchangeRateSnapshotEntity(
        currencyCode: 'USD',
        rateDate: '2026-01-01',
        rateToCdf: 2000,
      ),
      'usd': ExchangeRateSnapshotEntity(
        currencyCode: 'USD',
        rateDate: '2026-11-23',
        rateToCdf: 2500,
      ),
      'eur': ExchangeRateSnapshotEntity(
        currencyCode: 'EUR',
        rateDate: '2026-11-23',
        rateToCdf: 3000,
      ),
    },
  );
  const balances = [
    (walletId: 'bank', currency: 'USD', minor: 10000),
    (walletId: 'bank', currency: 'EUR', minor: 2000),
    (walletId: 'bank', currency: 'CDF', minor: -10000),
    (walletId: 'cash', currency: 'CDF', minor: 5000),
  ];

  test(
    'each wallet nets native balances before converting at latest rates',
    () {
      expect(walletBalanceTotal(balances, config, walletId: 'bank'), 309900);
      expect(walletBalanceTotal(balances, config, walletId: 'cash'), 50);
      expect(walletBalanceTotal(balances, config), 309950);
      expect(walletBalanceTotal(balances, config, walletId: 'empty'), 0);
    },
  );

  test('reference currency changes convert through CDF', () {
    expect(
      walletBalanceTotal(
        balances,
        config.copyWith(referenceCurrencyCode: 'USD'),
      ),
      closeTo(123.98, .000001),
    );
  });

  test('missing source or reference rates never produce a partial total', () {
    const unknown = [(walletId: 'bank', currency: 'CAD', minor: 100)];
    expect(walletBalanceTotal(unknown, config), isNull);
    expect(
      walletBalanceTotal(
        balances,
        config.copyWith(referenceCurrencyCode: 'CAD'),
      ),
      isNull,
    );
  });

  test('native amounts need no rate and empty wallets have a real zero', () {
    final nativeConfig = config.copyWith(referenceCurrencyCode: 'CAD');
    expect(
      walletBalanceTotal([
        (walletId: 'bank', currency: 'CAD', minor: -12345),
      ], nativeConfig),
      -123.45,
    );
    expect(walletBalanceTotal([], nativeConfig), 0);
  });

  test('opposite native balances cancel before looking for a rate', () {
    const transfer = [
      (walletId: 'bank', currency: 'CAD', minor: -9999),
      (walletId: 'cash', currency: 'CAD', minor: 9999),
    ];
    expect(walletBalanceTotal(transfer, config), 0);
    expect(walletBalanceTotal(transfer, config, walletId: 'bank'), isNull);
  });

  test('zero and non-finite rates are unavailable', () {
    for (final rate in [0.0, -1.0, double.nan, double.infinity]) {
      final invalid = config.copyWith(
        snapshotsByKey: {
          'usd': ExchangeRateSnapshotEntity(
            currencyCode: 'USD',
            rateDate: '2026-11-23',
            rateToCdf: rate,
          ),
        },
      );
      expect(walletBalanceTotal(balances, invalid), isNull);
    }
  });
}
