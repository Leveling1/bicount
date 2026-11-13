"""Test receipt races in a disposable, synthetic database on local Docker."""

from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[2]
MIGRATION = ROOT / "supabase/migrations/20261111100542_offline_creation_receipt.sql"
DB = "bicount_receipt_test_" + uuid4().hex[:16]
CONTAINER = "supabase_db_preprod"
USER = "00000000-0000-4000-8000-000000000971"
ROW = "00000000-0000-4000-8000-000000000973"
CREATION = "00000000-0000-4000-8000-000000000974"


def run_sql(sql, *, check=True):
    return subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "psql", "-X", "-qAt",
         "-U", "postgres", "-d", DB, "-v", "ON_ERROR_STOP=1"],
        input=sql, text=True, capture_output=True, check=check,
    )


def main():
    # Only this random-name synthetic database is ever removed.
    assert DB.startswith("bicount_receipt_test_") and len(DB) == 37
    subprocess.run(["docker", "exec", CONTAINER, "createdb", "-U", "postgres", DB], check=True)
    try:
        setup = """
        create schema auth;
        create schema bicount_sync;
        create function auth.uid() returns uuid language sql stable as
          $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
        grant usage on schema auth to authenticated;
        create table public.transactions (tid uuid primary key, uid uuid not null, amount integer);
        create table public.friends (sid uuid primary key, uid uuid not null);
        create table public.debts (debt_id uuid primary key, uid uuid not null);
        create table public.recurring_transfert (recurring_transfert_id uuid primary key, uid uuid not null);
        alter table public.transactions enable row level security;
        create policy owners on public.transactions for all to authenticated
          using (uid = auth.uid()) with check (uid = auth.uid());
        grant select, insert on public.transactions to authenticated;
        """
        run_sql(setup)
        rejected = run_sql(MIGRATION.read_text(encoding="utf-8"), check=False)
        if rejected.returncode == 0:
            raise RuntimeError("Experimental migration was accepted without local opt-in")
        run_sql("set bicount.local_preprod = 'allow';\n" + MIGRATION.read_text(encoding="utf-8"))
        query = f"""
        begin; set local role authenticated;
        select set_config('request.jwt.claim.sub', '{USER}', true);
        select public.bicount_create_once('transactions', '{ROW}', '{CREATION}',
          '{{"tid":"{ROW}","uid":"{USER}","amount":10}}'::jsonb)->>'status';
        select pg_sleep(0.5); commit;
        """
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(lambda _: run_sql(query, check=False), range(2)))
        statuses = [result.stdout for result in results]
        if not any("applied" in status for status in statuses):
            raise RuntimeError("Neither concurrent insertion succeeded")
        # A unique violation is acceptable during the race; retry must succeed.
        retry = run_sql(query).stdout
        if "already_applied" not in retry:
            raise RuntimeError("Retry did not find the creation receipt")
        counts = run_sql("select (select count(*) from public.transactions), "
                         "(select count(*) from bicount_sync.creation_receipts);").stdout.strip()
        if counts != "1|1":
            raise RuntimeError("Concurrent insertion created duplicate records")
        print("Concurrent create and retry: one row, one receipt")
    finally:
        subprocess.run(["docker", "exec", CONTAINER, "dropdb", "-U", "postgres", DB], check=True)


if __name__ == "__main__":
    main()
