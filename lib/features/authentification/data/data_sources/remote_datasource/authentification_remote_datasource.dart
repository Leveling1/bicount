import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;

abstract class AuthenticationRemoteDataSource {
  Future<entity.User> signInWithEmailAndPassword(String email, String password);
  Future<entity.User> signUp(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
