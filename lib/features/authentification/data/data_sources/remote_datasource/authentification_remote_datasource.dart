import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;

abstract class AuthenticationRemoteDataSource {
  Future<entity.UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<entity.UserEntity> signUp(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
