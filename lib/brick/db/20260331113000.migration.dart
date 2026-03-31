// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20260331113000_up = [
  InsertColumn(
    'salary_processing_mode',
    Column.integer,
    onTable: 'RecurringFundingModel',
  ),
  InsertColumn(
    'salary_reminder_status',
    Column.integer,
    onTable: 'RecurringFundingModel',
  ),
];

const List<MigrationCommand> _migration_20260331113000_down = [
  DropColumn('salary_processing_mode', onTable: 'RecurringFundingModel'),
  DropColumn('salary_reminder_status', onTable: 'RecurringFundingModel'),
];

@Migratable(
  version: '20260331113000',
  up: _migration_20260331113000_up,
  down: _migration_20260331113000_down,
)
class Migration20260331113000 extends Migration {
  const Migration20260331113000()
    : super(
        version: 20260331113000,
        up: _migration_20260331113000_up,
        down: _migration_20260331113000_down,
      );
}
