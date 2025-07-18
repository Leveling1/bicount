class TransactionModel {
  final String? id;
  final String name;
  final String type;
  final DateTime date;
  final DateTime createdAt;
  final double amount;
  final String? image;
  final String? frequency;
  final String sender;
  final String beneficiary;
  final String note;

  const TransactionModel({
    this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.amount,
    this.image,
    this.frequency,
    required this.sender,
    required this.beneficiary,
    required this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> data) {
    return TransactionModel(
      id: data["id"] ?? '',
      name: data["name"] ?? '',
      type: data["type"] ?? '',
      date: data["date"] is DateTime
          ? data["date"]
          : DateTime.tryParse(data["date"] ?? '') ?? DateTime.now(),
      createdAt: data["created_at"] is DateTime
          ? data["created_at"]
          : DateTime.tryParse(data["created_at"] ?? '') ?? DateTime.now(),
      amount: data["amount"] ?? '',
      image: data["image"] ?? '',
      frequency: data["frequency"] ?? '',
      sender: data["sender"] ?? '',
      beneficiary: data["beneficiary"] ?? '',
      note: data["note"] ?? '',
    );
  }
}
