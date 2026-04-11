import 'dart:convert';

import 'package:bicount/core/utils/number_format_utils.dart';

import '../../data/models/transaction.model.dart';

enum TransactionFrequency { cyclic, fixe }

class TransactionEntity {
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
    this.recurringTransfertId,
    required this.sender,
    required this.beneficiary,
    required this.note,
  });

  final String? id;
  final String tid;
  final String gtid;
  final String? uid;
  final String name;
  final int type;
  final DateTime date;
  final DateTime? createdAt;
  final double amount;
  final String currency;
  final String? image;
  final int? frequency;
  final String? recurringTransfertId;
  final String sender;
  final String beneficiary;
  final String note;

  String get currencySymbol => NumberFormatUtils.resolveSymbol(currency);

  factory TransactionEntity.fromJson(Map<String, dynamic> data) {
    return TransactionEntity(
      id: data['id'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      tid: data['tid'] as String? ?? '',
      gtid: data['gtid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as int? ?? 0,
      date: data['date'] is DateTime
          ? data['date'] as DateTime
          : DateTime.tryParse('${data['date'] ?? ''}') ?? DateTime.now(),
      createdAt: data['created_at'] is DateTime
          ? data['created_at'] as DateTime
          : DateTime.tryParse('${data['created_at'] ?? ''}'),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: '${data['currency'] ?? 'CDF'}',
      image: data['image'] as String?,
      frequency: data['frequency'] as int?,
      recurringTransfertId: data['recurring_transfert_id'] as String?,
      sender: data['sender']?['name'] ?? '',
      beneficiary: data['beneficiary'] is Map<String, dynamic>
          ? jsonEncode(data['beneficiary'])
          : data['beneficiary']?['name'] ?? '',
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'image': image,
      'frequency': frequency,
      'recurring_transfert_id': recurringTransfertId,
      'sender': sender,
      'beneficiary': jsonEncode(beneficiary),
      'note': note,
    };
  }

  factory TransactionEntity.fromTransaction(TransactionModel transaction) {
    return TransactionEntity(
      uid: transaction.uid,
      name: transaction.name,
      tid: transaction.tid!,
      gtid: transaction.gtid,
      type: transaction.type,
      date: DateTime.tryParse(transaction.date) ?? DateTime.now(),
      createdAt: DateTime.tryParse(transaction.createdAt ?? ''),
      amount: transaction.amount,
      currency: transaction.currency,
      image: transaction.image,
      frequency: transaction.frequency,
      recurringTransfertId: transaction.recurringTransfertId,
      sender: transaction.senderId,
      beneficiary: transaction.beneficiaryId,
      note: transaction.note,
    );
  }
}
