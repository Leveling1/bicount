// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20251201172247.migration.dart';
part '20251130001532.migration.dart';
part '20251201154524.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20251201172247(),
  const Migration20251130001532(),
  const Migration20251201154524(),
};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  20251201154524,
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
        SchemaColumn('uid', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('username', Column.varchar),
        SchemaColumn('email', Column.varchar),
        SchemaColumn('incomes', Column.Double),
        SchemaColumn('expenses', Column.Double),
        SchemaColumn('balance', Column.Double),
        SchemaColumn('company_income', Column.Double),
        SchemaColumn('personal_income', Column.Double),
        SchemaColumn('sid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['sid'], unique: true),
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
        SchemaColumn('category', Column.integer),
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
        SchemaColumn('type', Column.varchar),
        SchemaColumn('beneficiary_id', Column.varchar),
        SchemaColumn('sender_id', Column.varchar),
        SchemaColumn('date', Column.varchar),
        SchemaColumn('note', Column.varchar),
        SchemaColumn('amount', Column.Double),
        SchemaColumn('currency', Column.varchar),
        SchemaColumn('image', Column.varchar),
        SchemaColumn('frequency', Column.varchar),
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
