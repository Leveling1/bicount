// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20251005185213.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20251005185213(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'Start',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('id_user_link', Column.integer),
        SchemaColumn('name', Column.varchar),
        SchemaColumn('email', Column.varchar),
        SchemaColumn('id', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['id'], unique: true),
      },
    ),
  },
);
