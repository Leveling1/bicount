import 'dart:convert';

enum TransactionType { income, expense, transfer }

enum TransactionFrequency { cyclic, fixe }

enum Currency { USD, EUR, CDF }

class TransactionModel {
  final String? id;
  final String name;
  final TransactionType type;
  final DateTime date;
  final DateTime? createdAt;
  final double amount;
  final Currency currency;
  final String? image;
  final TransactionFrequency? frequency;
  final String sender;
  final Map<String, dynamic> beneficiary;
  final String note;

  const TransactionModel({
    this.id,
    required this.name,
    required this.type,
    required this.date,
    this.createdAt,
    required this.amount,
    required this.currency,
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
      type: TransactionType.values.firstWhere((e) => e.name == data['type']),
      date: data["date"] is DateTime
          ? data["date"]
          : DateTime.tryParse(data["date"] ?? '') ?? DateTime.now(),
      createdAt: data["created_at"] is DateTime
          ? data["created_at"]
          : DateTime.tryParse(data["created_at"] ?? '') ?? DateTime.now(),
      amount: (data["amount"] is double)
          ? data["amount"]
          : double.tryParse(data["amount"].toString()) ?? 0.0,
      currency: Currency.values.firstWhere((e) => e.name == data['currency']),
      image: data["image"],
      frequency: data["frequency"] != null
          ? TransactionFrequency.values.firstWhere(
              (e) => e.name == data['frequency'],
            )
          : null,
      sender: data["sender"]?['name'] ?? '',
      beneficiary: data["beneficiary"] is Map<String, dynamic>
          ? data["beneficiary"]
          : {"name": data["beneficiary"]?['name'] ?? ''},
      note: data["note"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type.name,
      "date": date.toIso8601String(),
      "amount": amount,
      "currency": currency.name,
      "image": image,
      "frequency": frequency?.name,
      "sender": sender,
      "beneficiary": jsonEncode(beneficiary),
      "note": note,
    };
  }
}
