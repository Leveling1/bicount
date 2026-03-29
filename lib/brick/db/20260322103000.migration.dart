// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

const List<MigrationCommand> _migration_20260322103000_up = [
  DropIndex('index_UserModel_on_sid'),
  DropColumn('sid', onTable: 'UserModel'),
  CreateIndex(columns: ['uid'], onTable: 'UserModel', unique: true),
];

const List<MigrationCommand> _migration_20260322103000_down = [
  DropIndex('index_UserModel_on_uid'),
  InsertColumn('sid', Column.varchar, onTable: 'UserModel', unique: true),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true),
];

@Migratable(
  version: '20260322103000',
  up: _migration_20260322103000_up,
  down: _migration_20260322103000_down,
)
class Migration20260322103000 extends Migration {
  const Migration20260322103000()
    : super(
        version: 20260322103000,
        up: _migration_20260322103000_up,
        down: _migration_20260322103000_down,
      );
}
