// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251202023307_up = [
  InsertTable('SubscriptionModel'),
  InsertColumn('subscription_id', Column.varchar, onTable: 'SubscriptionModel', unique: true),
  InsertColumn('sid', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('title', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('amount', Column.Double, onTable: 'SubscriptionModel'),
  InsertColumn('currency', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('frequency', Column.integer, onTable: 'SubscriptionModel'),
  InsertColumn('start_date', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('end_date', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('notes', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('status', Column.integer, onTable: 'SubscriptionModel'),
  CreateIndex(columns: ['subscription_id'], onTable: 'SubscriptionModel', unique: true)
];

const List<MigrationCommand> _migration_20251202023307_down = [
  DropTable('SubscriptionModel'),
  DropColumn('subscription_id', onTable: 'SubscriptionModel'),
  DropColumn('sid', onTable: 'SubscriptionModel'),
  DropColumn('title', onTable: 'SubscriptionModel'),
  DropColumn('amount', onTable: 'SubscriptionModel'),
  DropColumn('currency', onTable: 'SubscriptionModel'),
  DropColumn('frequency', onTable: 'SubscriptionModel'),
  DropColumn('start_date', onTable: 'SubscriptionModel'),
  DropColumn('end_date', onTable: 'SubscriptionModel'),
  DropColumn('notes', onTable: 'SubscriptionModel'),
  DropColumn('created_at', onTable: 'SubscriptionModel'),
  DropColumn('status', onTable: 'SubscriptionModel'),
  DropIndex('index_SubscriptionModel_on_subscription_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251202023307',
  up: _migration_20251202023307_up,
  down: _migration_20251202023307_down,
)
class Migration20251202023307 extends Migration {
  const Migration20251202023307()
    : super(
        version: 20251202023307,
        up: _migration_20251202023307_up,
        down: _migration_20251202023307_down,
      );
}
