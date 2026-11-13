import 'package:bicount/core/offline/offline_model.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum WalletKind { bankAccount, cash, card, mobileMoney, other }

enum WalletCardNetwork { visa, mastercard, other }

class WalletModel extends OfflineModel with Equatable {
  const WalletModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.createdAt,
    this.kind = WalletKind.other,
    this.cardNetwork,
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
    icon,
    color,
    isDefault,
    createdAt,
    archivedAt,
  ];
}
