import '../../../authentification/data/models/user_model.dart';
import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Stream<UserModel> getDataStream();
}
