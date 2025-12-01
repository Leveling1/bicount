// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251201172247_up = [
  DropColumn('profit', onTable: 'UserModel'),
  InsertColumn('balance', Column.Double, onTable: 'UserModel')
];

const List<MigrationCommand> _migration_20251201172247_down = [
  DropColumn('balance', onTable: 'UserModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251201172247',
  up: _migration_20251201172247_up,
  down: _migration_20251201172247_down,
)
class Migration20251201172247 extends Migration {
  const Migration20251201172247()
    : super(
        version: 20251201172247,
        up: _migration_20251201172247_up,
        down: _migration_20251201172247_down,
      );
}
