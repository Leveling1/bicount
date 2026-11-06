import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class GroupModel extends OfflineModel {
  final String cid;
  final String name;
  final String? description;
  final String? image;
  final int? number;
  final String createdAt;

  final String? gid;

  GroupModel({
    String? gid,
    required this.cid,
    required this.name,
    this.description,
    this.number,
    this.image,
    required this.createdAt,
  }) : gid = gid ?? const Uuid().v4(),
       super();
}
