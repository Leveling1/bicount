import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class FriendsModel extends OfflineModel {
  final String? uid;
  final String? fid;
  final String image;
  final String username;
  final String email;

  final double? give;

  final double? receive;

  final int relationType;

  final double? personalIncome;

  final double? companyIncome;

  final String sid;

  FriendsModel({
    String? sid,
    this.uid,
    this.fid,
    required this.image,
    required this.username,
    required this.email,
    this.give,
    this.receive,
    required this.relationType,
    this.personalIncome,
    this.companyIncome,
  }) : sid = sid ?? const Uuid().v4(),
       super();
}
