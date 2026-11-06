import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class TransactionModel extends OfflineModel {
  final String gtid;

  final String uid;

  final String name;

  final int type;

  final String beneficiaryId;

  final String senderId;

  final String date;

  final String note;

  final double amount;

  final String currency;

  final String? referenceCurrencyCode;

  final double? convertedAmount;

  final double? amountCdf;

  final double? rateToCdf;

  final String? fxRateDate;

  final String? fxSnapshotId;

  final String? image;

  final int? frequency;

  final int? category;

  final String? createdAt;

  final String? originId;

  final String? originOccurrenceDate;

  final String? recurringTransfertId;

  final String? recurringOccurrenceDate;

  final int? generationMode;

  final String? tid;

  TransactionModel({
    String? tid,
    required this.uid,
    required this.gtid,
    required this.name,
    required this.type,
    required this.beneficiaryId,
    required this.senderId,
    required this.date,
    required this.note,
    required this.amount,
    required this.currency,
    this.referenceCurrencyCode,
    this.convertedAmount,
    this.amountCdf,
    this.rateToCdf,
    this.fxRateDate,
    this.fxSnapshotId,
    this.category,
    this.image,
    this.frequency,
    this.createdAt,
    this.originId,
    this.originOccurrenceDate,
    this.recurringTransfertId,
    this.recurringOccurrenceDate,
    this.generationMode,
  }) : tid = tid ?? const Uuid().v4(),
       super();
}
