import 'package:bicount/core/offline/offline_model.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum WalletKind {
  bankAccount(1),
  cash(2),
  card(3),
  mobileMoney(4),
  other(0);

  const WalletKind(this.legacyIcon);

  final int legacyIcon;
}

enum WalletCardNetwork { visa, mastercard, other }

enum WalletMobileOperator {
  mpesa('mpesa'),
  orangeMoney('orange_money'),
  airtelMoney('airtel_money'),
  afrimoney('afrimoney');

  const WalletMobileOperator(this.code);

  final String code;

  static WalletMobileOperator? fromCode(Object? code) =>
      values.where((operator) => operator.code == code).firstOrNull;
}

class WalletModel extends OfflineModel with Equatable {
  const WalletModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.createdAt,
    this.kind = WalletKind.other,
    this.cardNetwork,
    this.mobileOperator,
    this.icon = 0,
    this.color = 0,
    this.isDefault = false,
    this.archivedAt,
  });

  final String id;
  final String ownerUid;
  final String name;
  final WalletKind kind;
  final WalletCardNetwork? cardNetwork;
  final WalletMobileOperator? mobileOperator;
  final int icon;
  final int color;
  final bool isDefault;
  final String createdAt;
  final String? archivedAt;

  static String principalId(String uid) =>
      const Uuid().v5(Namespace.url.value, uid);

  factory WalletModel.fromRow(Map<String, dynamic> row) => WalletModel(
    id: row['wallet_id'] as String,
    ownerUid: row['owner_uid'] as String,
    name: row['name'] as String,
    kind: WalletKind.values[(row['kind'] as num).toInt()],
    cardNetwork: row['card_network'] == null
        ? null
        : WalletCardNetwork.values[(row['card_network'] as num).toInt()],
    mobileOperator: WalletMobileOperator.fromCode(row['mobile_operator']),
    icon: (row['icon'] as num).toInt(),
    color: (row['color'] as num).toInt(),
    isDefault: row['is_default'] == true || row['is_default'] == 1,
    createdAt: row['created_at'] as String,
    archivedAt: row['archived_at'] as String?,
  );

  Map<String, dynamic> toRow({bool local = false}) => {
    'wallet_id': id,
    'owner_uid': ownerUid,
    'name': name,
    'kind': kind.index,
    'card_network': cardNetwork?.index,
    'mobile_operator': mobileOperator?.code,
    'icon': icon,
    'color': color,
    'is_default': local ? (isDefault ? 1 : 0) : isDefault,
    'created_at': createdAt,
    'archived_at': archivedAt,
  };

  @override
  List<Object?> get props => [
    id,
    ownerUid,
    name,
    kind,
    cardNetwork,
    mobileOperator,
    icon,
    color,
    isDefault,
    createdAt,
    archivedAt,
  ];
}
