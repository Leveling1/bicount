import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:equatable/equatable.dart';

class FriendDetailEntity extends Equatable {
  const FriendDetailEntity({
    required this.friend,
    required this.transactions,
    required this.displayCurrencyCode,
    required this.totalGiven,
    required this.totalReceived,
    required this.netBalance,
    required this.canEditProfile,
    required this.canShareProfile,
    required this.isLinkedProfile,
    required this.canUnlinkProfile,
    required this.canDeleteProfile,
  });

  final FriendsModel friend;
  final List<TransactionModel> transactions;
  final String displayCurrencyCode;
  final double totalGiven;
  final double totalReceived;
  final double netBalance;
  final bool canEditProfile;
  final bool canShareProfile;
  final bool isLinkedProfile;

  /// This profile is tied to a real Bicount account, so the two accounts can
  /// be separated.
  final bool canUnlinkProfile;

  /// This profile is tied to nobody, so it can be removed along with its
  /// history.
  final bool canDeleteProfile;

  @override
  List<Object?> get props => [
    friend,
    transactions,
    displayCurrencyCode,
    totalGiven,
    totalReceived,
    netBalance,
    canEditProfile,
    canShareProfile,
    isLinkedProfile,
    canUnlinkProfile,
    canDeleteProfile,
  ];
}
