// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20260325165928_up = [
  InsertTable('RecurringFundingModel'),
  InsertColumn('funding_type', Column.integer, onTable: 'AccountFundingModel'),
  InsertColumn(
    'recurring_funding_id',
    Column.varchar,
    onTable: 'RecurringFundingModel',
    unique: true,
  ),
  InsertColumn('uid', Column.varchar, onTable: 'RecurringFundingModel'),
  InsertColumn('source', Column.varchar, onTable: 'RecurringFundingModel'),
  InsertColumn('note', Column.varchar, onTable: 'RecurringFundingModel'),
  InsertColumn('amount', Column.Double, onTable: 'RecurringFundingModel'),
  InsertColumn('currency', Column.varchar, onTable: 'RecurringFundingModel'),
  InsertColumn('funding_type', Column.integer, onTable: 'RecurringFundingModel'),
  InsertColumn('frequency', Column.integer, onTable: 'RecurringFundingModel'),
  InsertColumn('start_date', Column.varchar, onTable: 'RecurringFundingModel'),
  InsertColumn(
    'next_funding_date',
    Column.varchar,
    onTable: 'RecurringFundingModel',
  ),
  InsertColumn(
    'last_processed_at',
    Column.varchar,
    onTable: 'RecurringFundingModel',
  ),
  InsertColumn('status', Column.integer, onTable: 'RecurringFundingModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'RecurringFundingModel'),
  CreateIndex(
    columns: ['recurring_funding_id'],
    onTable: 'RecurringFundingModel',
    unique: true,
  ),
  CreateIndex(columns: ['uid'], onTable: 'RecurringFundingModel'),
];

const List<MigrationCommand> _migration_20260325165928_down = [
  DropTable('RecurringFundingModel'),
  DropColumn('funding_type', onTable: 'AccountFundingModel'),
  DropIndex('index_RecurringFundingModel_on_recurring_funding_id'),
  DropIndex('index_RecurringFundingModel_on_uid'),
];

@Migratable(
  version: '20260325165928',
  up: _migration_20260325165928_up,
  down: _migration_20260325165928_down,
)
class Migration20260325165928 extends Migration {
  const Migration20260325165928()
    : super(
        version: 20260325165928,
        up: _migration_20260325165928_up,
        down: _migration_20260325165928_down,
      );
}
