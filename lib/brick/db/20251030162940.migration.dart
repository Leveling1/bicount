// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251030162940_up = [
  InsertTable('UserModel'),
  InsertTable('CompanyModel'),
  InsertTable('CompanyWithUserLinkModel'),
  InsertTable('GroupModel'),
  InsertTable('ProjectModel'),
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
  InsertColumn('cid', Column.varchar, onTable: 'GroupModel'),
  InsertColumn('name', Column.varchar, onTable: 'GroupModel'),
  InsertColumn('description', Column.varchar, onTable: 'GroupModel'),
  InsertColumn('image', Column.varchar, onTable: 'GroupModel'),
  InsertColumn('number', Column.integer, onTable: 'GroupModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'GroupModel'),
  InsertColumn('gid', Column.varchar, onTable: 'GroupModel', unique: true),
  InsertColumn('cid', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('name', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('initiator', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('description', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('image', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('state', Column.integer, onTable: 'ProjectModel'),
  InsertColumn('profit', Column.Double, onTable: 'ProjectModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('start_date', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('end_date', Column.varchar, onTable: 'ProjectModel'),
  InsertColumn('pid', Column.varchar, onTable: 'ProjectModel', unique: true),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true),
  CreateIndex(columns: ['cid'], onTable: 'CompanyModel', unique: true),
  CreateIndex(columns: ['lid'], onTable: 'CompanyWithUserLinkModel', unique: true),
  CreateIndex(columns: ['gid'], onTable: 'GroupModel', unique: true),
  CreateIndex(columns: ['pid'], onTable: 'ProjectModel', unique: true)
];

const List<MigrationCommand> _migration_20251030162940_down = [
  DropTable('UserModel'),
  DropTable('CompanyModel'),
  DropTable('CompanyWithUserLinkModel'),
  DropTable('GroupModel'),
  DropTable('ProjectModel'),
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
  DropColumn('cid', onTable: 'GroupModel'),
  DropColumn('name', onTable: 'GroupModel'),
  DropColumn('description', onTable: 'GroupModel'),
  DropColumn('image', onTable: 'GroupModel'),
  DropColumn('number', onTable: 'GroupModel'),
  DropColumn('created_at', onTable: 'GroupModel'),
  DropColumn('gid', onTable: 'GroupModel'),
  DropColumn('cid', onTable: 'ProjectModel'),
  DropColumn('name', onTable: 'ProjectModel'),
  DropColumn('initiator', onTable: 'ProjectModel'),
  DropColumn('description', onTable: 'ProjectModel'),
  DropColumn('image', onTable: 'ProjectModel'),
  DropColumn('state', onTable: 'ProjectModel'),
  DropColumn('profit', onTable: 'ProjectModel'),
  DropColumn('created_at', onTable: 'ProjectModel'),
  DropColumn('start_date', onTable: 'ProjectModel'),
  DropColumn('end_date', onTable: 'ProjectModel'),
  DropColumn('pid', onTable: 'ProjectModel'),
  DropIndex('index_UserModel_on_sid'),
  DropIndex('index_CompanyModel_on_cid'),
  DropIndex('index_CompanyWithUserLinkModel_on_lid'),
  DropIndex('index_GroupModel_on_gid'),
  DropIndex('index_ProjectModel_on_pid')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251030162940',
  up: _migration_20251030162940_up,
  down: _migration_20251030162940_down,
)
class Migration20251030162940 extends Migration {
  const Migration20251030162940()
    : super(
        version: 20251030162940,
        up: _migration_20251030162940_up,
        down: _migration_20251030162940_down,
      );
}
