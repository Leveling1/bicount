import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class UserModel extends entity.User {
  final String id;
  final String email;

  const UserModel({required this.id, required this.email})
    : super(id: id, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] ?? '', email: json['email'] ?? '');
  }

  factory UserModel.fromSupabase(supabase_auth.User user) {
    return UserModel(id: user.id, email: user.email ?? "unknown@gmail.com");
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }

  entity.User toUser() {
    return entity.User(id: id, email: email);
  }

  factory UserModel.fromUser(entity.User user) {
    return UserModel(id: user.id, email: user.email);
  }

  @override
  List<Object?> get props => [id, email];
}
