// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20251106162131.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20251106162131(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
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
        SchemaColumn('sales', Column.Double),
        SchemaColumn('expenses', Column.Double),
        SchemaColumn('profit', Column.Double),
        SchemaColumn('company_income', Column.Double),
        SchemaColumn('personal_income', Column.Double),
        SchemaColumn('sid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['sid'], unique: true),
      },
    ),
    SchemaTable(
      'UserLinkModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('user_a_id', Column.varchar),
        SchemaColumn('user_b_id', Column.varchar),
        SchemaColumn('link_type', Column.varchar),
        SchemaColumn('status', Column.varchar),
        SchemaColumn('lid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['lid'], unique: true),
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
        SchemaColumn('image', Column.varchar),
        SchemaColumn('username', Column.varchar),
        SchemaColumn('email', Column.varchar),
        SchemaColumn('sid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['sid'], unique: true),
      },
    ),
    SchemaTable(
      'UserLinksModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('user_a_id', Column.varchar),
        SchemaColumn('user_b_id', Column.varchar),
        SchemaColumn('link_type', Column.varchar),
        SchemaColumn('status', Column.varchar),
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('lid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['lid'], unique: true),
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
        SchemaColumn('created_at', Column.varchar),
        SchemaColumn('tid', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['tid'], unique: true),
      },
    ),
  },
);
