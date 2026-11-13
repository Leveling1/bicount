import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:sqflite_common/sqlite_api.dart';

Future<void> installWalletBalances(Database db, String uid) async {
  final batch = db.batch();
  for (final column in [
    'sender_id',
    'beneficiary_id',
    'sender_wallet_id',
    'beneficiary_wallet_id',
  ]) {
    batch.execute(
      'CREATE INDEX IF NOT EXISTS wallet_$column ON TransactionModel($column)',
    );
  }
  batch.execute('DROP VIEW IF EXISTS wallet_ledger_entries');
  batch.execute('''
    CREATE TABLE IF NOT EXISTS wallet_balances (
      wallet_id TEXT NOT NULL, currency_code TEXT NOT NULL,
      balance_minor INTEGER NOT NULL,
      PRIMARY KEY (wallet_id, currency_code)
    )
  ''');
  batch.execute('''
    CREATE TABLE IF NOT EXISTS wallet_balance_entries (
      tid TEXT NOT NULL, side INTEGER NOT NULL, wallet_id TEXT NOT NULL,
      currency_code TEXT NOT NULL, amount_minor INTEGER NOT NULL,
      PRIMARY KEY (tid, side)
    )
  ''');
  batch.execute(
    'CREATE TABLE IF NOT EXISTS wallet_balance_dirty (tid TEXT PRIMARY KEY)',
  );
  batch.execute(
    'CREATE TABLE IF NOT EXISTS wallet_balance_owner (uid TEXT PRIMARY KEY, principal_id TEXT NOT NULL)',
  );
  batch.rawInsert('INSERT OR IGNORE INTO wallet_balance_owner VALUES (?, ?)', [
    uid,
    WalletModel.principalId(uid),
  ]);
  batch.execute('''
    CREATE VIEW wallet_ledger_entries AS
    WITH parties AS (
      SELECT t.*, o.uid AS current_uid, o.principal_id,
        (t.sender_id = o.uid OR EXISTS (SELECT 1 FROM FriendsModel f
          WHERE f.sid = t.sender_id AND f.uid = o.uid)) AS is_sender,
        (t.beneficiary_id = o.uid OR EXISTS (SELECT 1 FROM FriendsModel f
          WHERE f.sid = t.beneficiary_id AND f.uid = o.uid)) AS is_beneficiary
      FROM TransactionModel t CROSS JOIN wallet_balance_owner o
    )
    SELECT tid, 0 AS side, COALESCE((SELECT w.wallet_id FROM WalletModel w
      WHERE w.wallet_id = sender_wallet_id AND w.owner_uid = current_uid), principal_id) AS wallet_id,
      upper(trim(currency)) AS currency_code, -CAST(round(amount * 100) AS INTEGER) AS amount_minor
      FROM parties WHERE is_sender AND (sender_id <> beneficiary_id OR type NOT IN (1, 3, 5))
    UNION ALL
    SELECT tid, 1, COALESCE((SELECT w.wallet_id FROM WalletModel w
      WHERE w.wallet_id = beneficiary_wallet_id AND w.owner_uid = current_uid), principal_id),
      upper(trim(currency)), CAST(round(amount * 100) AS INTEGER)
      FROM parties WHERE is_beneficiary AND (sender_id <> beneficiary_id OR type NOT IN (0, 2, 4))
  ''');
  // SQLite triggers cover local writes, batch snapshots, journal application,
  // reconciled deletions and relation changes across every write path.
  for (final event in ['INSERT', 'UPDATE', 'DELETE']) {
    final row = event == 'DELETE' ? 'OLD' : 'NEW';
    batch.execute('''
      CREATE TRIGGER IF NOT EXISTS wallet_movement_$event
      AFTER $event ON TransactionModel BEGIN
        INSERT INTO wallet_balance_dirty(tid) VALUES ($row.tid)
          ON CONFLICT(tid) DO NOTHING;
      END
    ''');
    batch.execute('''
      CREATE TRIGGER IF NOT EXISTS wallet_friend_$event
      AFTER $event ON FriendsModel
      ${event == 'UPDATE' ? 'WHEN OLD.uid IS NOT NEW.uid OR OLD.sid IS NOT NEW.sid' : ''}
      BEGIN
        INSERT INTO wallet_balance_dirty(tid)
          SELECT t.tid FROM TransactionModel t WHERE
          t.sender_id = $row.sid OR t.beneficiary_id = $row.sid
          ON CONFLICT(tid) DO NOTHING;
      END
    ''');
    batch.execute('''
      CREATE TRIGGER IF NOT EXISTS wallet_catalog_$event
      AFTER $event ON WalletModel
      ${event == 'UPDATE' ? 'WHEN OLD.wallet_id IS NOT NEW.wallet_id OR OLD.owner_uid IS NOT NEW.owner_uid' : ''}
      BEGIN
        INSERT INTO wallet_balance_dirty(tid)
          SELECT t.tid FROM TransactionModel t WHERE
          t.sender_wallet_id = $row.wallet_id OR t.beneficiary_wallet_id = $row.wallet_id
          ON CONFLICT(tid) DO NOTHING;
      END
    ''');
  }
  batch.execute('''
    CREATE TRIGGER IF NOT EXISTS wallet_balance_add AFTER INSERT ON wallet_balance_entries
    BEGIN
      INSERT INTO wallet_balances VALUES (NEW.wallet_id, NEW.currency_code, NEW.amount_minor)
      ON CONFLICT(wallet_id, currency_code)
      DO UPDATE SET balance_minor = balance_minor + NEW.amount_minor;
    END
  ''');
  batch.execute('''
    CREATE TRIGGER IF NOT EXISTS wallet_balance_subtract AFTER DELETE ON wallet_balance_entries
    BEGIN
      UPDATE wallet_balances SET balance_minor = balance_minor - OLD.amount_minor
      WHERE wallet_id = OLD.wallet_id AND currency_code = OLD.currency_code;
    END
  ''');
  batch.execute('''
    CREATE TABLE IF NOT EXISTS wallet_balance_metadata (version INTEGER PRIMARY KEY)
  ''');
  batch.execute('''
    CREATE TRIGGER IF NOT EXISTS wallet_project_movement AFTER INSERT ON wallet_balance_dirty
    BEGIN
      DELETE FROM wallet_balance_entries WHERE tid = NEW.tid;
      INSERT INTO wallet_balance_entries SELECT * FROM wallet_ledger_entries WHERE tid = NEW.tid;
      DELETE FROM wallet_balance_dirty WHERE tid = NEW.tid;
    END
  ''');
  batch.execute('''
    INSERT OR IGNORE INTO wallet_balance_dirty(tid)
      SELECT tid FROM TransactionModel WHERE NOT EXISTS (SELECT 1 FROM wallet_balance_metadata WHERE version = 2)
  ''');
  batch.execute('INSERT OR IGNORE INTO wallet_balance_metadata VALUES (2)');
  await batch.commit(noResult: true);
}

Future<List<WalletBalance>> readWalletBalances(Database db) async {
  final balances = await db.query('wallet_balances', orderBy: 'currency_code');
  return balances
      .map(
        (row) => (
          walletId: row['wallet_id'] as String,
          currency: row['currency_code'] as String,
          minor: row['balance_minor'] as int,
        ),
      )
      .toList(growable: false);
}
