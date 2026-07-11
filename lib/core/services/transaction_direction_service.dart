import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

enum TransactionSign { positive, negative, none }

enum TransactionOrigin { internal, external }

class TransactionDirection {
  const TransactionDirection({required this.sign, required this.origin});

  final TransactionSign sign;
  final TransactionOrigin origin;

  String get symbol => switch (sign) {
    TransactionSign.positive => '+',
    TransactionSign.negative => '-',
    TransactionSign.none => '',
  };

  bool get isExternal => origin == TransactionOrigin.external;
}

class TransactionDirectionService {
  const TransactionDirectionService({
    this.identityService = const TransactionParticipantIdentityService(),
  });

  final TransactionParticipantIdentityService identityService;

  TransactionDirection resolveFromEntity({
    required TransactionEntity transaction,
    required String currentUserId,
    required List<FriendsModel> friends,
  }) {
    return _resolve(
      senderId: transaction.sender,
      beneficiaryId: transaction.beneficiary,
      creatorId: transaction.uid,
      currentUserId: currentUserId,
      friends: friends,
    );
  }

  TransactionDirection resolveFromModel({
    required TransactionModel transaction,
    required String currentUserId,
    required List<FriendsModel> friends,
  }) {
    return _resolve(
      senderId: transaction.senderId,
      beneficiaryId: transaction.beneficiaryId,
      creatorId: transaction.uid,
      currentUserId: currentUserId,
      friends: friends,
    );
  }

  TransactionDirection _resolve({
    required String senderId,
    required String beneficiaryId,
    required String? creatorId,
    required String currentUserId,
    required List<FriendsModel> friends,
  }) {
    final participantIds = identityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );

    final TransactionSign sign;
    if (participantIds.contains(senderId)) {
      sign = TransactionSign.negative;
    } else if (participantIds.contains(beneficiaryId)) {
      sign = TransactionSign.positive;
    } else {
      sign = TransactionSign.none;
    }

    final origin =
        creatorId != null && creatorId.isNotEmpty && creatorId == currentUserId
        ? TransactionOrigin.internal
        : TransactionOrigin.external;

    return TransactionDirection(sign: sign, origin: origin);
  }
}
