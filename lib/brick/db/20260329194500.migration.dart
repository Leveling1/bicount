// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20260329194500_up = [
  InsertColumn('reference_currency_code', Column.varchar, onTable: 'UserModel'),
];

const List<MigrationCommand> _migration_20260329194500_down = [
  DropColumn('reference_currency_code', onTable: 'UserModel'),
];

@Migratable(
  version: '20260329194500',
  up: _migration_20260329194500_up,
  down: _migration_20260329194500_down,
)
class Migration20260329194500 extends Migration {
  const Migration20260329194500()
    : super(
        version: 20260329194500,
        up: _migration_20260329194500_up,
        down: _migration_20260329194500_down,
      );
}
