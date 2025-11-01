import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'transactions'),
)
class TransactionModel extends OfflineFirstWithSupabaseModel {
  @Sqlite(name: 'gtid')
  @Supabase(name: 'gtid')
  final String gtid;

  @Sqlite(name: 'name')
  @Supabase(name: 'name')
  final String name;

  @Sqlite(name: 'type')
  @Supabase(name: 'type')
  final String type;

  @Sqlite(name: 'beneficiary_id')
  @Supabase(name: 'beneficiary_id')
  final String beneficiaryId;

  @Sqlite(name: 'sender_id')
  @Supabase(name: 'sender_id')
  final String senderId;

  @Sqlite(name: 'date')
  @Supabase(name: 'date')
  final String date;

  @Sqlite(name: 'note')
  @Supabase(name: 'note')
  final String note;

  @Sqlite(name: 'amount')
  @Supabase(name: 'amount')
  final double amount;

  @Sqlite(name: 'currency')
  @Supabase(name: 'currency')
  final String currency;

  @Sqlite(name: 'image')
  @Supabase(name: 'image')
  final String? image;

  @Sqlite(name: 'frequency')
  @Supabase(name: 'frequency')
  final String? frequency;

  @Sqlite(name: 'created_at')
  @Supabase(name: 'created_at')
  final String? createdAt;

  @Supabase(unique: true, name: 'tid')
  @Sqlite(index: true, unique: true, name: 'tid')
  final String? tid;

  TransactionModel({
    String? tid,
    required this.gtid,
    required this.name,
    required this.type,
    required this.beneficiaryId,
    required this.senderId,
    required this.date,
    required this.note,
    required this.amount,
    required this.currency,
    this.image,
    this.frequency,
    required this.createdAt,
  })  : tid = tid ?? const Uuid().v4(),
        super();

  /// Méthode fromMap pour la désérialisation
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      tid: map['tid'] as String?,
      gtid: map['gtid'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      beneficiaryId: map['beneficiary_id'] as String,
      senderId: map['sender_id'] as String,
      date: map['date'] as String,
      note: map['note'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      image: map['image'] as String?,
      frequency: map['frequency'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Méthode toMap pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      if (tid != null) 'tid': tid,
      'gtid': gtid,
      'name': name,
      'type': type,
      'beneficiary_id': beneficiaryId,
      'sender_id': senderId,
      'date': date,
      'note': note,
      'amount': amount,
      'currency': currency,
      if (image != null) 'image': image,
      if (frequency != null) 'frequency': frequency,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}