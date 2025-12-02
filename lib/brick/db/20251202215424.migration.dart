// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251202215424_up = [
  InsertColumn('next_billing_date', Column.varchar, onTable: 'SubscriptionModel')
];

const List<MigrationCommand> _migration_20251202215424_down = [
  DropColumn('next_billing_date', onTable: 'SubscriptionModel')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251202215424',
  up: _migration_20251202215424_up,
  down: _migration_20251202215424_down,
)
class Migration20251202215424 extends Migration {
  const Migration20251202215424()
    : super(
        version: 20251202215424,
        up: _migration_20251202215424_up,
        down: _migration_20251202215424_down,
      );
}
