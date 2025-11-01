import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:flutter/foundation.dart';

import '../../../transaction/data/models/transaction.model.dart';

class HomeEntity {
  final UserModel ownData;

  HomeEntity({
    required this.ownData,
  });

  /// Supprimez complètement toMap() et fromMap() si non supportés
  /// Ou créez des méthodes simplifiées sans dépendre des sous-modèles

  /// Copie avec modification
  HomeEntity copyWith({
    UserModel? ownData,
    List<TransactionModel>? recentTransactions,
  }) {
    return HomeEntity(
      ownData: ownData ?? this.ownData,
    );
  }

  @override
  String toString() {
    return 'HomeEntity(ownData: $ownData)';
  }


  @override
  int get hashCode => ownData.hashCode;
}