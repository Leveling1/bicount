import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class UserModel extends OfflineModel {
  final String image;

  final String username;

  final String email;

  final double? incomes;

  final double? expenses;

  final double? balance;

  final double? companyIncome;

  final double? personalIncome;

  final String? referenceCurrencyCode;

  final String uid;

  UserModel({
    String? uid,
    required this.image,
    required this.username,
    required this.email,
    this.balance,
    this.incomes,
    this.expenses,
    this.companyIncome,
    this.personalIncome,
    this.referenceCurrencyCode,
  }) : uid = uid ?? const Uuid().v4(),
       super();
}
