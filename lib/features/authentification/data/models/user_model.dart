import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class UserModel extends entity.User {
  const UserModel({
    super.id,
    required super.uid,
    required super.email,
    required super.name,
    super.sales,
    super.expenses,
    super.profit,
    super.company_income,
    super.personal_income,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      sales: (json['sales'] as num?)?.toDouble(),
      expenses: (json['expenses'] as num?)?.toDouble(),
      profit: (json['profit'] as num?)?.toDouble(),
      company_income: (json['company_income'] as num?)?.toDouble(),
      personal_income: (json['personal_income'] as num?)?.toDouble(),
    );
  }

  factory UserModel.fromSupabase(supabase_auth.User user) {
    return UserModel(
      uid: user.id, // ⚡ tu peux adapter si `uuid` diffère dans ta DB
      email: user.email ?? "unknown@gmail.com",
      name: user.userMetadata?['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': super.id,
      'uuid': super.uid,
      'email': super.email,
      'name': super.name,
      'sales': super.sales,
      'expenses': super.expenses,
      'profit': super.profit,
      'company_income': super.company_income,
      'personal_income': super.personal_income,
    };
  }

  entity.User toUser() {
    return entity.User(
      id: super.id,
      uid: super.uid,
      email: super.email,
      name: super.name,
      sales: super.sales,
      expenses: super.expenses,
      profit: super.profit,
      company_income: super.company_income,
      personal_income: super.personal_income,
    );
  }

  factory UserModel.fromUser(entity.User user) {
    return UserModel(
      id: user.id,
      uid: user.uid,
      email: user.email,
      name: user.name,
      sales: user.sales,
      expenses: user.expenses,
      profit: user.profit,
      company_income: user.company_income,
      personal_income: user.personal_income,
    );
  }
}
