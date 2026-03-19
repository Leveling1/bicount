import 'package:bicount/features/main/domain/entities/main_entity.dart';

const mainShellTitles = ['', 'Graphs', 'Transaction', 'Profile'];

MainEntity prepareMainScreenData(MainEntity data) {
  final sortedTransactions = List.of(data.transactions);
  if (sortedTransactions.length > 1) {
    sortedTransactions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  return MainEntity(
    user: data.user,
    connectionState: data.connectionState,
    friends: data.friends,
    subscriptions: data.subscriptions,
    transactions: sortedTransactions,
  );
}
