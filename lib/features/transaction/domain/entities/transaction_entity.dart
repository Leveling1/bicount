import 'dart:convert';

import '../../data/models/transaction.model.dart';

enum TransactionFrequency { cyclic, fixe }

enum Currency { USD, EUR, CDF }

extension CurrencySymbol on Currency {
  String get symbol {
    switch (this) {
      case Currency.USD:
        return '\$';
      case Currency.EUR:
        return '€';
      case Currency.CDF:
        return 'FC';
    }
  }
}


class TransactionEntity {
  final String? id;
  final String tid;
  final String gtid;
  final String? uid;
  final String name;
  final String type;
  final DateTime date;
  final DateTime? createdAt;
  final double amount;
  final Currency currency;
  final String? image;
  final TransactionFrequency? frequency;
  final String sender;
  final String beneficiary;
  final String note;

  const TransactionEntity({
    this.id,
    this.uid,
    required this.tid,
    required this.gtid,
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

  factory TransactionEntity.fromJson(Map<String, dynamic> data) {
    return TransactionEntity(
      id: data["id"] ?? '',
      uid: data["uid"] ?? '',
      tid: data["tid"] ?? '',
      gtid: data["gtid"] ?? '',
      name: data["name"] ?? '',
      type: data['type'],
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
      "type": type,
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

  factory TransactionEntity.fromTransaction(TransactionModel transaction) {
    return TransactionEntity(
      uid: transaction.uid,
      name: transaction.name,
      tid: transaction.tid!,
      gtid: transaction.gtid,
      type: transaction.type,
      date: DateTime.tryParse(transaction.date)!,
      createdAt: DateTime.tryParse(transaction.createdAt ?? ''),
      amount: transaction.amount,
      currency: Currency.values.byName(transaction.currency),
      image: transaction.image,
      frequency: transaction.frequency != null ? TransactionFrequency.values.byName(transaction.frequency!) : null,
      sender: transaction.senderId,
      beneficiary: transaction.beneficiaryId,
      note: transaction.note,
    );
  }
}
