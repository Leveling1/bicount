class CompanyModel {
  final String? id;
  final String name;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CompanyModel({
    this.id,
    required this.name,
    this.description,
    this.email,
    this.phone,
    this.address,
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
      'email': email,
      'phone': phone,
      'address': address,
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
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      image: map['logoUrl'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}
