// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251130000355_up = [
  DropTable('UserLinkModel'),
  DropColumn('sales', onTable: 'UserModel'),
  InsertColumn('incomes', Column.Double, onTable: 'UserModel'),
  InsertColumn('personal_income', Column.Double, onTable: 'FriendsModel'),
  InsertColumn('company_income', Column.Double, onTable: 'FriendsModel'),
  InsertColumn('category', Column.integer, onTable: 'TransactionModel'),
  CreateIndex(columns: ['lid'], onTable: 'UserLinkModel', unique: true)
];

const List<MigrationCommand> _migration_20251130000355_down = [
  InsertTable('UserLinkModel'),
  DropColumn('incomes', onTable: 'UserModel'),
  DropColumn('personal_income', onTable: 'FriendsModel'),
  DropColumn('company_income', onTable: 'FriendsModel'),
  DropColumn('category', onTable: 'TransactionModel'),
  DropIndex('index_UserLinkModel_on_lid')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251130000355',
  up: _migration_20251130000355_up,
  down: _migration_20251130000355_down,
)
class Migration20251130000355 extends Migration {
  const Migration20251130000355()
    : super(
        version: 20251130000355,
        up: _migration_20251130000355_up,
        down: _migration_20251130000355_down,
      );
}
