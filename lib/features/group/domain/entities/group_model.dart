import 'dart:convert';
import 'dart:ffi';

class GroupEntity {
  final int? id;
  final String idCompany;
  final String name;
  final String? description;
  final String? image;
  final int? number;
  final DateTime createdAt;

  GroupEntity({
    this.id,
    required this.idCompany,
    required this.name,
    this.description,
    this.image,
    this.number,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convertir en Map (utile pour Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_company': idCompany,
      'name': name,
      'description': description,
      'logoUrl': image,
      'number': number,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Créer une instance depuis un Map
  factory GroupEntity.fromMap(Map<String, dynamic> map) {
    return GroupEntity(
      id: map['id'] ?? '',
      idCompany: map['id_company'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      image: map['image'],
      number: map['number'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
