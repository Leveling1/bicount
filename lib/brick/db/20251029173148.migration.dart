// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251029173148_up = [
  InsertTable('UserModel'),
  InsertColumn('uid', Column.varchar, onTable: 'UserModel'),
  InsertColumn('username', Column.varchar, onTable: 'UserModel'),
  InsertColumn('email', Column.varchar, onTable: 'UserModel'),
  InsertColumn('sales', Column.Double, onTable: 'UserModel'),
  InsertColumn('expenses', Column.Double, onTable: 'UserModel'),
  InsertColumn('profit', Column.Double, onTable: 'UserModel'),
  InsertColumn('company_income', Column.Double, onTable: 'UserModel'),
  InsertColumn('personal_income', Column.Double, onTable: 'UserModel'),
  InsertColumn('sid', Column.varchar, onTable: 'UserModel', unique: true),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true)
];

const List<MigrationCommand> _migration_20251029173148_down = [
  DropTable('UserModel'),
  DropColumn('uid', onTable: 'UserModel'),
  DropColumn('username', onTable: 'UserModel'),
  DropColumn('email', onTable: 'UserModel'),
  DropColumn('sales', onTable: 'UserModel'),
  DropColumn('expenses', onTable: 'UserModel'),
  DropColumn('profit', onTable: 'UserModel'),
  DropColumn('company_income', onTable: 'UserModel'),
  DropColumn('personal_income', onTable: 'UserModel'),
  DropColumn('sid', onTable: 'UserModel'),
  DropIndex('index_UserModel_on_sid')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251029173148',
  up: _migration_20251029173148_up,
  down: _migration_20251029173148_down,
)
class Migration20251029173148 extends Migration {
  const Migration20251029173148()
    : super(
        version: 20251029173148,
        up: _migration_20251029173148_up,
        down: _migration_20251029173148_down,
      );
}
