// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260507144610_up = [
  DropColumn('recurring_transfert_id', onTable: 'TransactionModel'),
  DropColumn('recurring_occurrence_date', onTable: 'TransactionModel'),
];

const List<MigrationCommand> _migration_20260507144610_down = [
  InsertColumn(
    'recurring_transfert_id',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
  InsertColumn(
    'recurring_occurrence_date',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260507144610',
  up: _migration_20260507144610_up,
  down: _migration_20260507144610_down,
)
class Migration20260507144610 extends Migration {
  const Migration20260507144610()
    : super(
        version: 20260507144610,
        up: _migration_20260507144610_up,
        down: _migration_20260507144610_down,
      );
}
