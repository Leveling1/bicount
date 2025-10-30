// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20251030021126.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20251030021126(),};

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
  },
);
