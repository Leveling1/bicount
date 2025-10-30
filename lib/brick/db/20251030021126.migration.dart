// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251030021126_up = [
  InsertTable('UserModel'),
  InsertTable('CompanyModel'),
  InsertTable('CompanyWithUserLinkModel'),
  InsertColumn('uid', Column.varchar, onTable: 'UserModel'),
  InsertColumn('username', Column.varchar, onTable: 'UserModel'),
  InsertColumn('email', Column.varchar, onTable: 'UserModel'),
  InsertColumn('sales', Column.Double, onTable: 'UserModel'),
  InsertColumn('expenses', Column.Double, onTable: 'UserModel'),
  InsertColumn('profit', Column.Double, onTable: 'UserModel'),
  InsertColumn('company_income', Column.Double, onTable: 'UserModel'),
  InsertColumn('personal_income', Column.Double, onTable: 'UserModel'),
  InsertColumn('sid', Column.varchar, onTable: 'UserModel', unique: true),
  InsertColumn('name', Column.varchar, onTable: 'CompanyModel'),
  InsertColumn('description', Column.varchar, onTable: 'CompanyModel'),
  InsertColumn('image', Column.varchar, onTable: 'CompanyModel'),
  InsertColumn('sales', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('expenses', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('profit', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('salary', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('equipment', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('service', Column.Double, onTable: 'CompanyModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'CompanyModel'),
  InsertColumn('cid', Column.varchar, onTable: 'CompanyModel', unique: true),
  InsertColumn('company_id', Column.varchar, onTable: 'CompanyWithUserLinkModel'),
  InsertColumn('user_id', Column.varchar, onTable: 'CompanyWithUserLinkModel'),
  InsertColumn('role', Column.varchar, onTable: 'CompanyWithUserLinkModel'),
  InsertColumn('lid', Column.varchar, onTable: 'CompanyWithUserLinkModel', unique: true),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true),
  CreateIndex(columns: ['cid'], onTable: 'CompanyModel', unique: true),
  CreateIndex(columns: ['lid'], onTable: 'CompanyWithUserLinkModel', unique: true)
];

const List<MigrationCommand> _migration_20251030021126_down = [
  DropTable('UserModel'),
  DropTable('CompanyModel'),
  DropTable('CompanyWithUserLinkModel'),
  DropColumn('uid', onTable: 'UserModel'),
  DropColumn('username', onTable: 'UserModel'),
  DropColumn('email', onTable: 'UserModel'),
  DropColumn('sales', onTable: 'UserModel'),
  DropColumn('expenses', onTable: 'UserModel'),
  DropColumn('profit', onTable: 'UserModel'),
  DropColumn('company_income', onTable: 'UserModel'),
  DropColumn('personal_income', onTable: 'UserModel'),
  DropColumn('sid', onTable: 'UserModel'),
  DropColumn('name', onTable: 'CompanyModel'),
  DropColumn('description', onTable: 'CompanyModel'),
  DropColumn('image', onTable: 'CompanyModel'),
  DropColumn('sales', onTable: 'CompanyModel'),
  DropColumn('expenses', onTable: 'CompanyModel'),
  DropColumn('profit', onTable: 'CompanyModel'),
  DropColumn('salary', onTable: 'CompanyModel'),
  DropColumn('equipment', onTable: 'CompanyModel'),
  DropColumn('service', onTable: 'CompanyModel'),
  DropColumn('created_at', onTable: 'CompanyModel'),
  DropColumn('cid', onTable: 'CompanyModel'),
  DropColumn('company_id', onTable: 'CompanyWithUserLinkModel'),
  DropColumn('user_id', onTable: 'CompanyWithUserLinkModel'),
  DropColumn('role', onTable: 'CompanyWithUserLinkModel'),
  DropColumn('lid', onTable: 'CompanyWithUserLinkModel'),
  DropIndex('index_UserModel_on_sid'),
  DropIndex('index_CompanyModel_on_cid'),
  DropIndex('index_CompanyWithUserLinkModel_on_lid')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251030021126',
  up: _migration_20251030021126_up,
  down: _migration_20251030021126_down,
)
class Migration20251030021126 extends Migration {
  const Migration20251030021126()
    : super(
        version: 20251030021126,
        up: _migration_20251030021126_up,
        down: _migration_20251030021126_down,
      );
}
