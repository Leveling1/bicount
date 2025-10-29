// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20251029173148.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20251029173148(),};

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
  },
);
