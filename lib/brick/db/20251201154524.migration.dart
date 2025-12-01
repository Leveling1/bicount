// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251201154524_up = [
  InsertTable('AccountFundingModel'),
  InsertColumn('funding_id', Column.varchar, onTable: 'AccountFundingModel', unique: true),
  InsertColumn('sid', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn('amount', Column.Double, onTable: 'AccountFundingModel'),
  InsertColumn('currency', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn('category', Column.integer, onTable: 'AccountFundingModel'),
  InsertColumn('source', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn('note', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn('date', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'AccountFundingModel'),
  CreateIndex(columns: ['funding_id'], onTable: 'AccountFundingModel', unique: true)
];

const List<MigrationCommand> _migration_20251201154524_down = [
  DropTable('AccountFundingModel'),
  DropColumn('funding_id', onTable: 'AccountFundingModel'),
  DropColumn('sid', onTable: 'AccountFundingModel'),
  DropColumn('amount', onTable: 'AccountFundingModel'),
  DropColumn('currency', onTable: 'AccountFundingModel'),
  DropColumn('category', onTable: 'AccountFundingModel'),
  DropColumn('source', onTable: 'AccountFundingModel'),
  DropColumn('note', onTable: 'AccountFundingModel'),
  DropColumn('date', onTable: 'AccountFundingModel'),
  DropColumn('created_at', onTable: 'AccountFundingModel'),
  DropIndex('index_AccountFundingModel_on_funding_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251201154524',
  up: _migration_20251201154524_up,
  down: _migration_20251201154524_down,
)
class Migration20251201154524 extends Migration {
  const Migration20251201154524()
    : super(
        version: 20251201154524,
        up: _migration_20251201154524_up,
        down: _migration_20251201154524_down,
      );
}
