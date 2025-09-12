import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class UserModel extends entity.User {
  final String id;
  final String email;
  final String name;
  final int? sales;
  final int? expenses;
  final int? profit;

  const UserModel(this.name, this.sales, this.expenses, this.profit, {required this.id, required this.email})
    : super(id: id, email: email, name: name, sales: sales, expenses: expenses, profit: profit);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['name'] ?? '',
      json['sales'],
      json['expenses'],
      json['profit'],
      id: json['id'] ?? '',
      email: json['email'] ?? '',
    );
  }

  factory UserModel.fromSupabase(supabase_auth.User user) {
    return UserModel(
      user.userMetadata?['name'] ?? '',
      null,
      null,
      null,
      id: user.id,
      email: user.email ?? "unknown@gmail.com"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'sales': sales,
      'expenses': expenses,
      'profit': profit,
    };
  }

  entity.User toUser() {
    return entity.User(
      id: id,
      email: email,
      name: name,
      sales: sales,
      expenses: expenses,
      profit: profit,
    );
  }

  factory UserModel.fromUser(entity.User user) {
    return UserModel(
      user.name,
      user.sales,
      user.expenses,
      user.profit,
      id: user.id,
      email: user.email
    );
  }

  @override
  List<Object?> get props => [id, email, name, sales, expenses, profit];
}
