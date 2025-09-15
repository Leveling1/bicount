import 'dart:convert';
import 'dart:ffi';

class CompanyModel {
  final int? id;
  final String name;
  final String? description;
  final String? image;
  final double? sales;
  final double? expenses;
  final double? profit;
  final double? salary;
  final double? equipment;
  final double? service;
  final DateTime createdAt;

  CompanyModel({
    this.id,
    required this.name,
    this.description,
    this.image,
    this.sales,
    this.expenses,
    this.profit,
    this.salary,
    this.equipment,
    this.service,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convertir en Map (utile pour Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': image,
      'sales': sales,
      'expenses': expenses,
      'profit': profit,
      'salary': salary,
      'equipment': equipment,
      'service': service,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Créer une instance depuis un Map
  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      image: map['image'],
      sales: (map['sales'] as num?)?.toDouble(),
      expenses: (map['expenses'] as num?)?.toDouble(),
      profit: (map['profit'] as num?)?.toDouble(),
      salary: (map['salary'] as num?)?.toDouble(),
      equipment: (map['equipment'] as num?)?.toDouble(),
      service: (map['service'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
