import 'dart:convert';
import 'dart:ffi';

class ProjectModel {
  final int? id;
  final int idCompany;
  final String name;
  final String initiator;
  final String? description;
  final String? image;
  final String? state;
  final DateTime createdAt;

  ProjectModel({
    this.id,
    required this.idCompany,
    required this.name,
    required this.initiator,
    this.description,
    this.image,
    this.state,
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
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
