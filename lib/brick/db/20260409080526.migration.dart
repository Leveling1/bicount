// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260409080526_up = [
  DropColumn('uid', onTable: 'UserModel'),
  InsertTable('RecurringTransfertModel'),
  InsertColumn('uid', Column.varchar, onTable: 'UserModel', unique: true),
  InsertColumn(
    'recurring_transfert_id',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
    unique: true,
  ),
  InsertColumn('uid', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn(
    'transaction_type',
    Column.integer,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn('title', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn('note', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn('amount', Column.Double, onTable: 'RecurringTransfertModel'),
  InsertColumn('currency', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn('sender_id', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn(
    'beneficiary_id',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn('frequency', Column.integer, onTable: 'RecurringTransfertModel'),
  InsertColumn(
    'start_date',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'next_due_date',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn('end_date', Column.varchar, onTable: 'RecurringTransfertModel'),
  InsertColumn('status', Column.integer, onTable: 'RecurringTransfertModel'),
  InsertColumn(
    'execution_mode',
    Column.integer,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'reminder_enabled',
    Column.boolean,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'last_generated_at',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'last_confirmed_at',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'created_at',
    Column.varchar,
    onTable: 'RecurringTransfertModel',
  ),
  InsertColumn(
    'recurring_transfert_id',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
  InsertColumn(
    'recurring_occurrence_date',
    Column.varchar,
    onTable: 'TransactionModel',
  ),
  InsertColumn('generation_mode', Column.integer, onTable: 'TransactionModel'),
  CreateIndex(
    columns: ['recurring_transfert_id'],
    onTable: 'RecurringTransfertModel',
    unique: true,
  ),
  CreateIndex(
    columns: ['uid'],
    onTable: 'RecurringTransfertModel',
    unique: false,
  ),
  CreateIndex(columns: ['sid'], onTable: 'UserModel', unique: true),
];

const List<MigrationCommand> _migration_20260409080526_down = [
  DropTable('RecurringTransfertModel'),
  DropColumn('uid', onTable: 'UserModel'),
  DropColumn('recurring_transfert_id', onTable: 'RecurringTransfertModel'),
  DropColumn('uid', onTable: 'RecurringTransfertModel'),
  DropColumn('transaction_type', onTable: 'RecurringTransfertModel'),
  DropColumn('title', onTable: 'RecurringTransfertModel'),
  DropColumn('note', onTable: 'RecurringTransfertModel'),
  DropColumn('amount', onTable: 'RecurringTransfertModel'),
  DropColumn('currency', onTable: 'RecurringTransfertModel'),
  DropColumn('sender_id', onTable: 'RecurringTransfertModel'),
  DropColumn('beneficiary_id', onTable: 'RecurringTransfertModel'),
  DropColumn('frequency', onTable: 'RecurringTransfertModel'),
  DropColumn('start_date', onTable: 'RecurringTransfertModel'),
  DropColumn('next_due_date', onTable: 'RecurringTransfertModel'),
  DropColumn('end_date', onTable: 'RecurringTransfertModel'),
  DropColumn('status', onTable: 'RecurringTransfertModel'),
  DropColumn('execution_mode', onTable: 'RecurringTransfertModel'),
  DropColumn('reminder_enabled', onTable: 'RecurringTransfertModel'),
  DropColumn('last_generated_at', onTable: 'RecurringTransfertModel'),
  DropColumn('last_confirmed_at', onTable: 'RecurringTransfertModel'),
  DropColumn('created_at', onTable: 'RecurringTransfertModel'),
  DropColumn('recurring_transfert_id', onTable: 'TransactionModel'),
  DropColumn('recurring_occurrence_date', onTable: 'TransactionModel'),
  DropColumn('generation_mode', onTable: 'TransactionModel'),
  DropIndex('index_RecurringTransfertModel_on_recurring_transfert_id'),
  DropIndex('index_RecurringTransfertModel_on_uid'),
  DropIndex('index_UserModel_on_sid'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260409080526',
  up: _migration_20260409080526_up,
  down: _migration_20260409080526_down,
)
class Migration20260409080526 extends Migration {
  const Migration20260409080526()
    : super(
        version: 20260409080526,
        up: _migration_20260409080526_up,
        down: _migration_20260409080526_down,
      );
}
