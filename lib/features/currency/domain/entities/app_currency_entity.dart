import 'package:equatable/equatable.dart';

class AppCurrencyEntity extends Equatable {
  const AppCurrencyEntity({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimals = 2,
    this.displayOrder = 0,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String symbol;
  final int decimals;
  final int displayOrder;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'decimals': decimals,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  factory AppCurrencyEntity.fromJson(Map<String, dynamic> json) {
    return AppCurrencyEntity(
      code: '${json['code'] ?? 'CDF'}'.toUpperCase(),
      name: '${json['name'] ?? 'Congolese franc'}',
      symbol: '${json['symbol'] ?? 'Fc'}',
      decimals: (json['decimals'] as num?)?.toInt() ?? 2,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static const fallbackCurrencies = <AppCurrencyEntity>[
    AppCurrencyEntity(
      code: 'CDF',
      name: 'Congolese franc',
      symbol: 'Fc',
      displayOrder: 0,
    ),
    AppCurrencyEntity(
      code: 'USD',
      name: 'US dollar',
      symbol: '\$',
      displayOrder: 1,
    ),
    AppCurrencyEntity(
      code: 'EUR',
      name: 'Euro',
      symbol: 'EUR',
      displayOrder: 2,
    ),
  ];

  @override
  List<Object?> get props => [
    code,
    name,
    symbol,
    decimals,
    displayOrder,
    isActive,
  ];
}
