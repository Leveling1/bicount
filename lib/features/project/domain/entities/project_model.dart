import 'dart:convert';
import 'dart:ffi';

class ProjectModel {
  final int? id;
  final String idCompany;
  final String name;
  final String initiator;
  final String? description;
  final String? image;
  final int? state;
  final double? profit;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endDate;


  ProjectModel({
    this.id,
    required this.idCompany,
    required this.name,
    required this.initiator,
    required this.startDate,
    this.endDate,
    this.description,
    this.image,
    this.state,
    this.profit,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convertir en Map (utile pour Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_company': idCompany,
      'name': name,
      'initiator': initiator,
      'description': description,
      'logoUrl': image,
      'state': state,
      'profit': profit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Créer une instance depuis un Map
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',
      idCompany: map['id_company'] ?? '',
      name: map['name'] ?? '',
      initiator: map['initiator'] ?? '',
      description: map['description'],
      image: map['image'],
      state: map['number'],
      profit: map['profit'] != null ? (map['profit'] as num).toDouble() : 0.0,
      startDate: DateTime.tryParse(map['start_date'] ?? '') ?? DateTime.now(),
      endDate: map['end_date'] != null && map['end_date'].isNotEmpty
          ? DateTime.tryParse(map['end_date'])
          : null,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
