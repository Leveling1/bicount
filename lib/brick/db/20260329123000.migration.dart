// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20260329123000_up = [
  InsertColumn(
    'reference_currency_code',
    Column.varchar,
    onTable: 'AccountFundingModel',
  ),
  InsertColumn(
    'converted_amount',
    Column.Double,
    onTable: 'AccountFundingModel',
  ),
  InsertColumn('amount_cdf', Column.Double, onTable: 'AccountFundingModel'),
  InsertColumn('rate_to_cdf', Column.Double, onTable: 'AccountFundingModel'),
  InsertColumn('fx_rate_date', Column.varchar, onTable: 'AccountFundingModel'),
  InsertColumn(
    'fx_snapshot_id',
    Column.varchar,
    onTable: 'AccountFundingModel',
  ),
  InsertColumn(
    'reference_currency_code',
    Column.varchar,
    onTable: 'SubscriptionModel',
  ),
  InsertColumn('converted_amount', Column.Double, onTable: 'SubscriptionModel'),
  InsertColumn('amount_cdf', Column.Double, onTable: 'SubscriptionModel'),
  InsertColumn('rate_to_cdf', Column.Double, onTable: 'SubscriptionModel'),
  InsertColumn('fx_rate_date', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn('fx_snapshot_id', Column.varchar, onTable: 'SubscriptionModel'),
  InsertColumn(
    'reference_currency_code',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
  InsertColumn('converted_amount', Column.Double, onTable: 'TransactionModel'),
  InsertColumn('amount_cdf', Column.Double, onTable: 'TransactionModel'),
  InsertColumn('rate_to_cdf', Column.Double, onTable: 'TransactionModel'),
  InsertColumn('fx_rate_date', Column.varchar, onTable: 'TransactionModel'),
  InsertColumn('fx_snapshot_id', Column.varchar, onTable: 'TransactionModel'),
];

const List<MigrationCommand> _migration_20260329123000_down = [
  DropColumn('reference_currency_code', onTable: 'AccountFundingModel'),
  DropColumn('converted_amount', onTable: 'AccountFundingModel'),
  DropColumn('amount_cdf', onTable: 'AccountFundingModel'),
  DropColumn('rate_to_cdf', onTable: 'AccountFundingModel'),
  DropColumn('fx_rate_date', onTable: 'AccountFundingModel'),
  DropColumn('fx_snapshot_id', onTable: 'AccountFundingModel'),
  DropColumn('reference_currency_code', onTable: 'SubscriptionModel'),
  DropColumn('converted_amount', onTable: 'SubscriptionModel'),
  DropColumn('amount_cdf', onTable: 'SubscriptionModel'),
  DropColumn('rate_to_cdf', onTable: 'SubscriptionModel'),
  DropColumn('fx_rate_date', onTable: 'SubscriptionModel'),
  DropColumn('fx_snapshot_id', onTable: 'SubscriptionModel'),
  DropColumn('reference_currency_code', onTable: 'TransactionModel'),
  DropColumn('converted_amount', onTable: 'TransactionModel'),
  DropColumn('amount_cdf', onTable: 'TransactionModel'),
  DropColumn('rate_to_cdf', onTable: 'TransactionModel'),
  DropColumn('fx_rate_date', onTable: 'TransactionModel'),
  DropColumn('fx_snapshot_id', onTable: 'TransactionModel'),
];

@Migratable(
  version: '20260329123000',
  up: _migration_20260329123000_up,
  down: _migration_20260329123000_down,
)
class Migration20260329123000 extends Migration {
  const Migration20260329123000()
    : super(
        version: 20260329123000,
        up: _migration_20260329123000_up,
        down: _migration_20260329123000_down,
      );
}
