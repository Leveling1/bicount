import 'dart:convert';

class CompanyModel {
  final int? id;
  final String name;
  final String? description;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CompanyModel({
    this.id,
    required this.name,
    this.description,
    this.image,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convertir en Map (utile pour Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Créer une instance depuis un Map
  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      image: map['logoUrl'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}
