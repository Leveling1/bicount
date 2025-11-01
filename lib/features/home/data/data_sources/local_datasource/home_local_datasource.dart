import 'package:bicount/features/authentification/data/models/user.model.dart';

abstract class HomeLocalDataSource {
  Stream<UserModel> getOwnData();
}
