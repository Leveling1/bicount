import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

class OfflineFinanceDeltaCalculator {
  const OfflineFinanceDeltaCalculator();

  UserModel applyTransactionToUser({
    required UserModel user,
    required bool isSender,
    required double amount,
    required int category,
  }) {
    final direction = isSender ? -amount : amount;
    return UserModel(
      uid: user.uid,
      image: user.image,
      username: user.username,
      email: user.email,
      balance: _sum(user.balance, direction),
      incomes: _sum(user.incomes, isSender ? 0 : amount),
      expenses: _sum(user.expenses, isSender ? amount : 0),
      companyIncome: _sum(
        user.companyIncome,
        category == Constants.company ? direction : 0,
      ),
      personalIncome: _sum(
        user.personalIncome,
        category == Constants.personal ? direction : 0,
      ),
    );
  }

  FriendsModel applyTransactionToFriend({
    required FriendsModel friend,
    required bool isSender,
    required double amount,
    required int category,
  }) {
    final direction = isSender ? -amount : amount;
    return FriendsModel(
      sid: friend.sid,
      uid: friend.uid,
      fid: friend.fid,
      image: friend.image,
      username: friend.username,
      email: friend.email,
      give: _sum(friend.give, isSender ? amount : 0),
      receive: _sum(friend.receive, isSender ? 0 : amount),
      relationType: friend.relationType,
      personalIncome: _sum(
        friend.personalIncome,
        category == Constants.personal ? direction : 0,
      ),
      companyIncome: _sum(
        friend.companyIncome,
        category == Constants.company ? direction : 0,
      ),
    );
  }

  UserModel applyPersonalFundingToUser({
    required UserModel user,
    required double amount,
  }) {
    return UserModel(
      uid: user.uid,
      image: user.image,
      username: user.username,
      email: user.email,
      balance: _sum(user.balance, amount),
      incomes: _sum(user.incomes, amount),
      expenses: user.expenses,
      companyIncome: user.companyIncome,
      personalIncome: _sum(user.personalIncome, amount),
    );
  }

  CompanyModel applyCompanyFundingToCompany({
    required CompanyModel company,
    required double amount,
  }) {
    return CompanyModel(
      cid: company.cid,
      name: company.name,
      description: company.description,
      image: company.image,
      sales: company.sales,
      expenses: company.expenses,
      profit: _sum(company.profit, amount),
      salary: company.salary,
      equipment: company.equipment,
      service: company.service,
      createdAt: company.createdAt,
    );
  }

  double _sum(double? current, double delta) => (current ?? 0) + delta;
}
