// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251005185213_up = [
  InsertTable('Start'),
  InsertColumn('id_user_link', Column.integer, onTable: 'Start'),
  InsertColumn('name', Column.varchar, onTable: 'Start'),
  InsertColumn('email', Column.varchar, onTable: 'Start'),
  InsertColumn('id', Column.varchar, onTable: 'Start', unique: true),
  CreateIndex(columns: ['id'], onTable: 'Start', unique: true)
];

const List<MigrationCommand> _migration_20251005185213_down = [
  DropTable('Start'),
  DropColumn('id_user_link', onTable: 'Start'),
  DropColumn('name', onTable: 'Start'),
  DropColumn('email', onTable: 'Start'),
  DropColumn('id', onTable: 'Start'),
  DropIndex('index_Start_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251005185213',
  up: _migration_20251005185213_up,
  down: _migration_20251005185213_down,
)
class Migration20251005185213 extends Migration {
  const Migration20251005185213()
    : super(
        version: 20251005185213,
        up: _migration_20251005185213_up,
        down: _migration_20251005185213_down,
      );
}
