// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260507143446_up = [
  InsertTable('DebtModel'),
  InsertColumn('debt_id', Column.varchar, onTable: 'DebtModel', unique: true),
  InsertColumn('created_by', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('lender_id', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('borrower_id', Column.varchar, onTable: 'DebtModel'),
  InsertColumn(
    'principal_transaction_id',
    Column.varchar,
    onTable: 'DebtModel',
    unique: true,
  ),
  InsertColumn('title', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('note', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('currency', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('principal_amount', Column.Double, onTable: 'DebtModel'),
  InsertColumn(
    'expected_repayment_amount',
    Column.Double,
    onTable: 'DebtModel',
  ),
  InsertColumn('repaid_amount', Column.Double, onTable: 'DebtModel'),
  InsertColumn('remaining_amount', Column.Double, onTable: 'DebtModel'),
  InsertColumn('due_date', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('status', Column.integer, onTable: 'DebtModel'),
  InsertColumn('reminder_enabled', Column.boolean, onTable: 'DebtModel'),
  InsertColumn(
    'last_due_notification_at',
    Column.varchar,
    onTable: 'DebtModel',
  ),
  InsertColumn('closed_at', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('created_at', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('updated_at', Column.varchar, onTable: 'DebtModel'),
  InsertColumn('origin_id', Column.varchar, onTable: 'TransactionModel'),
  InsertColumn(
    'origin_occurrence_date',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
  CreateIndex(columns: ['debt_id'], onTable: 'DebtModel', unique: true),
  CreateIndex(columns: ['created_by'], onTable: 'DebtModel', unique: false),
  CreateIndex(columns: ['lender_id'], onTable: 'DebtModel', unique: false),
  CreateIndex(columns: ['borrower_id'], onTable: 'DebtModel', unique: false),
  CreateIndex(
    columns: ['principal_transaction_id'],
    onTable: 'DebtModel',
    unique: true,
  ),
];

const List<MigrationCommand> _migration_20260507143446_down = [
  DropTable('DebtModel'),
  DropColumn('debt_id', onTable: 'DebtModel'),
  DropColumn('created_by', onTable: 'DebtModel'),
  DropColumn('lender_id', onTable: 'DebtModel'),
  DropColumn('borrower_id', onTable: 'DebtModel'),
  DropColumn('principal_transaction_id', onTable: 'DebtModel'),
  DropColumn('title', onTable: 'DebtModel'),
  DropColumn('note', onTable: 'DebtModel'),
  DropColumn('currency', onTable: 'DebtModel'),
  DropColumn('principal_amount', onTable: 'DebtModel'),
  DropColumn('expected_repayment_amount', onTable: 'DebtModel'),
  DropColumn('repaid_amount', onTable: 'DebtModel'),
  DropColumn('remaining_amount', onTable: 'DebtModel'),
  DropColumn('due_date', onTable: 'DebtModel'),
  DropColumn('status', onTable: 'DebtModel'),
  DropColumn('reminder_enabled', onTable: 'DebtModel'),
  DropColumn('last_due_notification_at', onTable: 'DebtModel'),
  DropColumn('closed_at', onTable: 'DebtModel'),
  DropColumn('created_at', onTable: 'DebtModel'),
  DropColumn('updated_at', onTable: 'DebtModel'),
  DropColumn('origin_id', onTable: 'TransactionModel'),
  DropColumn('origin_occurrence_date', onTable: 'TransactionModel'),
  DropIndex('index_DebtModel_on_debt_id'),
  DropIndex('index_DebtModel_on_created_by'),
  DropIndex('index_DebtModel_on_lender_id'),
  DropIndex('index_DebtModel_on_borrower_id'),
  DropIndex('index_DebtModel_on_principal_transaction_id'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260507143446',
  up: _migration_20260507143446_up,
  down: _migration_20260507143446_down,
)
class Migration20260507143446 extends Migration {
  const Migration20260507143446()
    : super(
        version: 20260507143446,
        up: _migration_20260507143446_up,
        down: _migration_20260507143446_down,
      );
}
