"""Exercise the installed local receipt API with newly-created test users."""
import os
import subprocess
from uuid import UUID, uuid4

from preprod_api_smoke import BASE, WORKDIR, local_sql, request


def main():
    status = subprocess.run(
        ['supabase', 'status', '--workdir', str(WORKDIR), '-o', 'env'],
        capture_output=True, text=True, check=True, shell=os.name == 'nt',
    )
    env = dict(line.split('=', 1) for line in status.stdout.splitlines() if '=' in line)
    env = {key: value.strip().strip('"') for key, value in env.items()}
    if env.get('API_URL') != BASE:
        raise RuntimeError('Refusing to test a non-local Supabase API')
    anon, service = env['ANON_KEY'], env['SERVICE_ROLE_KEY']
    user_id = None
    transaction_id = str(uuid4())
    creation_id = str(uuid4())
    flutter_tid = str(uuid4())
    lost_tid = str(uuid4())
    remote_win_tid = str(uuid4())
    local_win_tid = str(uuid4())
    deleted_tid = str(uuid4())
    pilot_enabled = False
    try:
        signup = request('POST', '/auth/v1/signup', anon, data={
            'email': f'receipt-{uuid4().hex}@example.test',
            'password': f'Test-{uuid4().hex}-aA1!',
        })
        user_id = str(UUID(signup['user']['id']))
        token = signup['access_token']
        payload = {'tid': transaction_id, 'uid': user_id, 'gtid': str(uuid4()),
                   'name': 'Receipt API test', 'type': 0, 'sender_id': user_id,
                   'beneficiary_id': user_id, 'date': '2026-01-01T00:00:00Z',
                   'amount': 12, 'currency': 'CDF'}
        args = {'p_table': 'transactions', 'p_id': transaction_id,
                'p_creation_id': creation_id, 'p_payload': payload}
        first = request('POST', '/rest/v1/rpc/bicount_create_once', anon, token, args)
        retry = request('POST', '/rest/v1/rpc/bicount_create_once', anon, token, args)
        if first.get('status') != 'applied' or retry.get('status') != 'already_applied':
            raise RuntimeError('Local creation receipt did not confirm retry')
        if 'row' in retry:
            raise RuntimeError('Receipt unexpectedly exposed a saved row')
        rows = request('GET', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token)
        if len(rows) != 1:
            raise RuntimeError('Local creation did not produce exactly one visible row')
        different = dict(args, p_payload=dict(payload, amount=99))
        conflict = request('POST', '/rest/v1/rpc/bicount_create_once', anon, token, different)
        if conflict.get('status') != 'conflict':
            raise RuntimeError('Changed retry payload was not rejected')
        # This deletion targets only the synthetic record created above.
        local_sql(f"DELETE FROM public.transactions WHERE tid = '{transaction_id}'::uuid AND uid = '{user_id}'::uuid")
        after_delete = request('POST', '/rest/v1/rpc/bicount_create_once', anon, token, args)
        if after_delete.get('status') != 'already_applied':
            raise RuntimeError('Receipt did not prevent recreation after deletion')
        rows = request('GET', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token)
        if rows:
            raise RuntimeError('A deleted transaction was recreated')
        print('Local HTTP creation and retry: passed')
        # Do not change an existing local pilot. The user is freshly created.
        local_sql("DO $$ DECLARE active boolean; others integer; BEGIN "
                  "SELECT enabled_for_all, cardinality(pilot_user_uids) INTO active, others "
                  "FROM bicount_sync.capture_config WHERE singleton FOR UPDATE; "
                  "IF active THEN RETURN; END IF; IF others > 0 THEN "
                  "RAISE EXCEPTION 'Existing pilot is active'; END IF; "
                  "UPDATE bicount_sync.capture_config SET pilot_user_uids = "
                  f"ARRAY['{user_id}'::uuid] WHERE singleton; END $$;")
        pilot_enabled = True
        test_env = os.environ.copy()
        test_env.update({'BICOUNT_PREPROD_TEST_ANON': anon,
                         'BICOUNT_PREPROD_TEST_TOKEN': token,
                         'BICOUNT_PREPROD_TEST_UID': user_id,
                         'BICOUNT_PREPROD_TEST_CREATION_TID': flutter_tid,
                         'BICOUNT_PREPROD_TEST_LOST_TID': lost_tid,
                         'BICOUNT_PREPROD_TEST_REMOTE_WIN_TID': remote_win_tid,
                         'BICOUNT_PREPROD_TEST_LOCAL_WIN_TID': local_win_tid})
        test_env['BICOUNT_PREPROD_TEST_DELETED_TID'] = deleted_tid
        subprocess.run(['flutter', 'test', '--no-pub',
                        'supabase/tests/preprod_creation_flutter_test.dart',
                        'supabase/tests/preprod_conflict_flutter_test.dart'],
                       cwd=WORKDIR.parents[2], env=test_env, check=True,
                       shell=os.name == 'nt')
    finally:
        if user_id:
            if pilot_enabled:
                local_sql("UPDATE bicount_sync.capture_config SET pilot_user_uids = "
                          f"array_remove(pilot_user_uids, '{user_id}'::uuid) "
                          f"WHERE singleton AND '{user_id}'::uuid = ANY(pilot_user_uids)")
            # These UUIDs were generated in this test, never selected from app data.
            local_sql(f"DELETE FROM public.transactions WHERE tid = '{transaction_id}'::uuid AND uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM public.transactions WHERE tid = '{flutter_tid}'::uuid AND uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM public.transactions WHERE tid = '{lost_tid}'::uuid AND uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM public.transactions WHERE tid IN ('{remote_win_tid}'::uuid, '{local_win_tid}'::uuid) AND uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM public.transactions WHERE tid = '{deleted_tid}'::uuid AND uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM bicount_sync.creation_receipts WHERE user_uid = '{user_id}'::uuid AND creation_id = '{creation_id}'::uuid")
            local_sql(f"DELETE FROM bicount_sync.creation_receipts WHERE user_uid = '{user_id}'::uuid AND record_id = '{flutter_tid}'::uuid")
            local_sql(f"DELETE FROM bicount_sync.creation_receipts WHERE user_uid = '{user_id}'::uuid AND record_id = '{lost_tid}'::uuid")
            request('DELETE', f'/auth/v1/admin/users/{user_id}', service, service)
            local_sql(f"DELETE FROM public.bicount_sync_events WHERE user_uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM public.bicount_sync_clock WHERE user_uid = '{user_id}'::uuid")
            local_sql(f"DELETE FROM bicount_sync.record_clock WHERE (table_name = 'users' AND record_id = '{user_id}'::uuid) OR (table_name = 'transactions' AND record_id IN ('{transaction_id}'::uuid, '{remote_win_tid}'::uuid, '{local_win_tid}'::uuid, '{deleted_tid}'::uuid, '{flutter_tid}'::uuid, '{lost_tid}'::uuid))")


if __name__ == '__main__':
    main()
