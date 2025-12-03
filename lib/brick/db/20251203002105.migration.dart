// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251203002105_up = [
  DropColumn('type', onTable: 'TransactionModel'),
  DropColumn('frequency', onTable: 'TransactionModel'),
  InsertColumn('relation_type', Column.integer, onTable: 'FriendsModel'),
  InsertColumn('category', Column.integer, onTable: 'SubscriptionModel'),
  InsertColumn('type', Column.integer, onTable: 'TransactionModel'),
  InsertColumn('frequency', Column.integer, onTable: 'TransactionModel')
];

const List<MigrationCommand> _migration_20251203002105_down = [
  DropColumn('relation_type', onTable: 'FriendsModel'),
  DropColumn('category', onTable: 'SubscriptionModel'),
  DropColumn('type', onTable: 'TransactionModel'),
  DropColumn('frequency', onTable: 'TransactionModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251203002105',
  up: _migration_20251203002105_up,
  down: _migration_20251203002105_down,
)
class Migration20251203002105 extends Migration {
  const Migration20251203002105()
    : super(
        version: 20251203002105,
        up: _migration_20251203002105_up,
        down: _migration_20251203002105_down,
      );
}
