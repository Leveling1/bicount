// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20260331113000.migration.dart';
part '20260329194500.migration.dart';
part '20260329123000.migration.dart';
part '20260325165928.migration.dart';
part '20251130001532.migration.dart';
part '20251201154524.migration.dart';
part '20251201172247.migration.dart';
part '20251202023307.migration.dart';
part '20251202215424.migration.dart';
part '20251203002105.migration.dart';
part '20260322103000.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20260331113000(),
  const Migration20260329194500(),
  const Migration20260329123000(),
  const Migration20260325165928(),
  const Migration20251130001532(),
  const Migration20251201154524(),
  const Migration20251201172247(),
  const Migration20251202023307(),
  const Migration20251202215424(),
  const Migration20251203002105(),
  const Migration20260322103000(),
};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  20260331113000,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'MemojiModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('link', Column.varchar),
        SchemaColumn('sexe', Column.varchar),
        SchemaColumn('mid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['mid'], unique: true),
      },
    ),
    SchemaTable(
      'UserModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('username', Column.varchar),
        SchemaColumn('email', Column.varchar),
        SchemaColumn('incomes', Column.Double),
        SchemaColumn('expenses', Column.Double),
        SchemaColumn('balance', Column.Double),
        SchemaColumn('company_income', Column.Double),
        SchemaColumn('personal_income', Column.Double),
        SchemaColumn('reference_currency_code', Column.varchar),
        SchemaColumn('uid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['uid'], unique: true),
      },
    ),
    SchemaTable(
      'CompanyModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('description', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('sales', Column.Double),
        SchemaColumn('expenses', Column.Double),
        SchemaColumn('profit', Column.Double),
        SchemaColumn('salary', Column.Double),
        SchemaColumn('equipment', Column.Double),
        SchemaColumn('service', Column.Double),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('cid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['cid'], unique: true),
      },
    ),
    SchemaTable(
      'CompanyWithUserLinkModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('company_id', Column.varchar),
        SchemaColumn('user_id', Column.varchar),
        SchemaColumn('role', Column.varchar),
        SchemaColumn('lid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['lid'], unique: true),
      },
    ),
    SchemaTable(
      'GroupModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('cid', Column.varchar),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('description', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('number', Column.integer),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('gid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['gid'], unique: true),
      },
    ),
    SchemaTable(
      'FriendsModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('uid', Column.varchar),
        SchemaColumn('fid', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('username', Column.varchar),
        SchemaColumn('email', Column.varchar),
        SchemaColumn('give', Column.Double),
        SchemaColumn('receive', Column.Double),
        SchemaColumn('relation_type', Column.integer),
        SchemaColumn('personal_income', Column.Double),
        SchemaColumn('company_income', Column.Double),
        SchemaColumn('sid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['sid'], unique: true),
      },
    ),
    SchemaTable(
      'AccountFundingModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('funding_id', Column.varchar, unique: true),
        SchemaColumn('sid', Column.varchar),
        SchemaColumn('amount', Column.Double),
        SchemaColumn('currency', Column.varchar),
        SchemaColumn('reference_currency_code', Column.varchar),
        SchemaColumn('converted_amount', Column.Double),
        SchemaColumn('amount_cdf', Column.Double),
        SchemaColumn('rate_to_cdf', Column.Double),
        SchemaColumn('fx_rate_date', Column.varchar),
        SchemaColumn('fx_snapshot_id', Column.varchar),
        SchemaColumn('category', Column.integer),
        SchemaColumn('funding_type', Column.integer),
        SchemaColumn('source', Column.varchar),
        SchemaColumn('note', Column.varchar),
        SchemaColumn('date', Column.varchar),
        SchemaColumn('created_at', Column.varchar),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['funding_id'], unique: true),
      },
    ),
    SchemaTable(
      'RecurringFundingModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('recurring_funding_id', Column.varchar, unique: true),
        SchemaColumn('uid', Column.varchar),
        SchemaColumn('source', Column.varchar),
        SchemaColumn('note', Column.varchar),
        SchemaColumn('amount', Column.Double),
        SchemaColumn('currency', Column.varchar),
        SchemaColumn('funding_type', Column.integer),
        SchemaColumn('frequency', Column.integer),
        SchemaColumn('start_date', Column.varchar),
        SchemaColumn('next_funding_date', Column.varchar),
        SchemaColumn('last_processed_at', Column.varchar),
        SchemaColumn('status', Column.integer),
        SchemaColumn('salary_processing_mode', Column.integer),
        SchemaColumn('salary_reminder_status', Column.integer),
        SchemaColumn('created_at', Column.varchar),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['recurring_funding_id'], unique: true),
        SchemaIndex(columns: ['uid'], unique: false),
      },
    ),
    SchemaTable(
      'ProjectModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('cid', Column.varchar),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('initiator', Column.varchar),
        SchemaColumn('description', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('state', Column.integer),
        SchemaColumn('profit', Column.Double),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('start_date', Column.varchar),
        SchemaColumn('end_date', Column.varchar),
        SchemaColumn('pid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['pid'], unique: true),
      },
    ),
    SchemaTable(
      'SubscriptionModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('subscription_id', Column.varchar, unique: true),
        SchemaColumn('sid', Column.varchar),
        SchemaColumn('title', Column.varchar),
        SchemaColumn('amount', Column.Double),
        SchemaColumn('currency', Column.varchar),
        SchemaColumn('reference_currency_code', Column.varchar),
        SchemaColumn('converted_amount', Column.Double),
        SchemaColumn('amount_cdf', Column.Double),
        SchemaColumn('rate_to_cdf', Column.Double),
        SchemaColumn('fx_rate_date', Column.varchar),
        SchemaColumn('fx_snapshot_id', Column.varchar),
        SchemaColumn('frequency', Column.integer),
        SchemaColumn('start_date', Column.varchar),
        SchemaColumn('next_billing_date', Column.varchar),
        SchemaColumn('end_date', Column.varchar),
        SchemaColumn('notes', Column.varchar),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('category', Column.integer),
        SchemaColumn('status', Column.integer),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['subscription_id'], unique: true),
      },
    ),
    SchemaTable(
      'TransactionModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('gtid', Column.varchar),
        SchemaColumn('uid', Column.varchar),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('type', Column.integer),
        SchemaColumn('beneficiary_id', Column.varchar),
        SchemaColumn('sender_id', Column.varchar),
        SchemaColumn('date', Column.varchar),
        SchemaColumn('note', Column.varchar),
        SchemaColumn('amount', Column.Double),
        SchemaColumn('currency', Column.varchar),
        SchemaColumn('reference_currency_code', Column.varchar),
        SchemaColumn('converted_amount', Column.Double),
        SchemaColumn('amount_cdf', Column.Double),
        SchemaColumn('rate_to_cdf', Column.Double),
        SchemaColumn('fx_rate_date', Column.varchar),
        SchemaColumn('fx_snapshot_id', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('frequency', Column.integer),
        SchemaColumn('category', Column.integer),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('tid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['tid'], unique: true),
      },
    ),
  },
);
