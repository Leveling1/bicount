import '../../../authentification/data/models/user.model.dart';
import '../entities/home.dart';
import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Stream<HomeEntity> getDataStream();
}
