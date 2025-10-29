import 'package:equatable/equatable.dart';

class UserEntity {
  final String? sid;
  final String uid;
  final String email;
  final String? username;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? companyIncome;
  final double? personalIncome;

  const UserEntity({
    required this.sid,
    required this.uid,
    required this.email,
    required this.username,
    this.sales,
    this.expenses,
    this.profit,
    this.companyIncome,
    this.personalIncome,
  });

  @override
  String toString() {
    return 'User(id: $sid, uuid: $uid, email: $email, name: $username, sales: $sales, expenses: $expenses, profit: $profit, company_income: $companyIncome, personal_income: $personalIncome)';
  }

  factory UserEntity.fromData(Map<String, dynamic> data) {
    return UserEntity(
      sid: data['sid'],
      uid: data['uuid'] as String,
      email: data['email'] as String,
      username: data['username'] as String,
      sales: data['sales'] as double?,
      expenses: data['expenses'] as double?,
      profit: data['profit'] as double?,
      companyIncome: (data['company_income'] as num?)?.toDouble(),
      personalIncome: (data['personal_income'] as num?)?.toDouble(),
    );
  }
}