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
    required this.canShareProfile,
    required this.isLinkedProfile,
  });

  final FriendsModel friend;
  final List<TransactionModel> transactions;
  final String displayCurrencyCode;
  final double totalGiven;
  final double totalReceived;
  final double netBalance;
  final bool canShareProfile;
  final bool isLinkedProfile;

  @override
  List<Object?> get props => [
    friend,
    transactions,
    displayCurrencyCode,
    totalGiven,
    totalReceived,
    netBalance,
    canShareProfile,
    isLinkedProfile,
  ];
}
