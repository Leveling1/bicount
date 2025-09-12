import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final int? sales;
  final int? expenses;
  final int? profit;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.sales,
    this.expenses,
    this.profit,
  });

  @override
  List<Object?> get props => [id, email, name, sales, expenses, profit];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, sales: $sales, expenses: $expenses, profit: $profit)';
  }

  factory User.fromData(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      sales: data['sales'] as int?,
      expenses: data['expenses'] as int?,
      profit: data['profit'] as int?,
    );
  }
}
