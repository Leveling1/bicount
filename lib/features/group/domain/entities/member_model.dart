class MemberModel {
  final int? id;
  final String? UID;
  final String name;
  final String role;
  final String? image;

  MemberModel({
    this.id,
    this.UID,
    required this.name,
    this.image,
    required this.role,
  });

  /// Convertir en Map (utile pour Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'UID': UID,
      'name': name,
      'logoUrl': image,
      'role': role,
    };
  }

  /// Créer une instance depuis un Map
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      UID: map['UID'] ?? '',
      name: map['name'] ?? '',
      image: map['image'],
      role: map['role'] ?? '',
    );
  }
}
