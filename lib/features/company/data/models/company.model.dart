import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class CompanyModel extends OfflineModel {
  final String name;
  final String? description;
  final String? image;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? salary;
  final double? equipment;
  final double? service;
  final String createdAt;

  final String? cid;

  CompanyModel({
    String? cid,
    required this.name,
    this.description,
    this.image,
    this.sales,
    this.expenses,
    this.profit,
    this.salary,
    this.equipment,
    this.service,
    required this.createdAt,
  }) : cid = cid ?? const Uuid().v4(),
       super();
}
