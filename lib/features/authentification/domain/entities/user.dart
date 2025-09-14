import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String uid;
  final String email;
  final String name;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? company_income;
  final double? personal_income;

  const User({
    required this.id,
    required this.uid,
    required this.email,
    required this.name,
    this.sales,
    this.expenses,
    this.profit,
    this.company_income,
    this.personal_income,
  });

  @override
  List<Object?> get props => [
    id,
    uid,
    email,
    name,
    sales,
    expenses,
    profit,
    company_income,
    personal_income,
  ];

  @override
  String toString() {
    return 'User(id: $id, uuid: $uid, email: $email, name: $name, sales: $sales, expenses: $expenses, profit: $profit, company_income: $company_income, personal_income: $personal_income)';
  }

  factory User.fromData(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      uid: data['uuid'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      sales: data['sales'] as double?,
      expenses: data['expenses'] as double?,
      profit: data['profit'] as double?,
      company_income: (data['company_income'] as num?)?.toDouble(),
      personal_income: (data['personal_income'] as num?)?.toDouble(),
    );
  }
}

