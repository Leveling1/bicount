import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class ProjectModel extends OfflineModel {
  final String cid;
  final String name;
  final String initiator;
  final String? description;
  final String? image;
  final int? state;
  final double? profit;
  final String? createdAt;
  final String startDate;
  final String? endDate;

  final String? pid;

  ProjectModel({
    String? pid,
    required this.cid,
    required this.name,
    required this.initiator,
    required this.startDate,
    this.description,
    this.image,
    this.state,
    this.profit,
    this.endDate,
    this.createdAt,
  }) : pid = pid ?? const Uuid().v4(),
       super();
}
