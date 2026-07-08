// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260705164703_up = [
  DropColumn('uid', onTable: 'UserModel'),
  InsertColumn('uid', Column.varchar, onTable: 'UserModel', unique: true),
  InsertColumn('expected_repayment_currency', Column.varchar, onTable: 'DebtModel'),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true)
];

const List<MigrationCommand> _migration_20260705164703_down = [
  DropColumn('uid', onTable: 'UserModel'),
  DropColumn('expected_repayment_currency', onTable: 'DebtModel'),
  DropIndex('index_UserModel_on_sid')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260705164703',
  up: _migration_20260705164703_up,
  down: _migration_20260705164703_down,
)
class Migration20260705164703 extends Migration {
  const Migration20260705164703()
    : super(
        version: 20260705164703,
        up: _migration_20260705164703_up,
        down: _migration_20260705164703_down,
      );
}
