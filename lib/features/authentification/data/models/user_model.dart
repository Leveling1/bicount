import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class UserModel extends entity.User {
  final double? company_income;
  final double? personal_income;
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.sales,
    super.expenses,
    super.profit,
    this.company_income,
    this.personal_income,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      sales: json['sales'],
      expenses: json['expenses'],
      profit: json['profit'],
      company_income: json['company_income'],
      personal_income: json['personal_income'],
    );
  }

  factory UserModel.fromSupabase(supabase_auth.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? "unknown@gmail.com",
      name: user.userMetadata?['name'] ?? '',
      sales: null,
      expenses: null,
      profit: null,
      company_income: null,
      personal_income: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': super.id,
      'email': super.email,
      'name': super.name,
      'sales': super.sales,
      'expenses': super.expenses,
      'profit': super.profit,
      'company_income': company_income,
      'personal_income': personal_income,
    };
  }

  entity.User toUser() {
    return entity.User(
      id: super.id,
      email: super.email,
      name: super.name,
      sales: super.sales,
      expenses: super.expenses,
      profit: super.profit,
      // Note: toUser() might lose company_income and personal_income if entity.User doesn't have them
      // Assuming for now it's intended to convert to the base User entity.
    );
  }

  factory UserModel.fromUser(entity.User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      sales: user.sales,
      expenses: user.expenses,
      profit: user.profit,
      // This will cause an error if the passed user doesn't have these fields.
      // A more robust way would be to check the type.
      // company_income: (user is UserModel) ? user.company_income : null,
      // personal_income: (user is UserModel) ? user.personal_income : null,
    );
  }

  @override
  // Les props sont déjà définis dans la classe `entity.User` (qui hérite de Equatable)
  // Pas besoin de les redéfinir ici si les champs sont les mêmes.
  // Si entity.User n'étend pas Equatable, alors cette surcharge est correcte.
  List<Object?> get props =>
      [
        super.id,
        super.email,
        super.name,
        super.sales,
        super.expenses,
        super.profit,
        company_income,
        personal_income
      ];
}
