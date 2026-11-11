"""Exercise only the isolated local API with a disposable synthetic account."""

import asyncio
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import subprocess
import urllib.error
import urllib.request
from uuid import UUID, uuid4


ROOT = Path(__file__).resolve().parents[2]
WORKDIR = ROOT / 'supabase' / '.temp' / 'preprod'
BASE = 'http://127.0.0.1:54321'


def request(method, route, key, token=None, data=None):
    headers = {'apikey': key, 'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    body = None if data is None else json.dumps(data).encode('utf-8')
    req = urllib.request.Request(BASE + route, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            raw = response.read()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as error:
        raise RuntimeError(f'Local {method} {route.split("?")[0]} failed: {error.code}') from error


def local_sql(sql):
    subprocess.run(
        ['docker', 'exec', 'supabase_db_preprod', 'psql', '-U', 'postgres',
         '-v', 'ON_ERROR_STOP=1', '-c', sql],
        check=True, capture_output=True, text=True,
    )


async def check_realtime(anon, token):
    import websockets

    url = 'ws://127.0.0.1:54321/realtime/v1/websocket?apikey=' + anon + '&vsn=2.0.0'
    try:
        async with websockets.connect(url, open_timeout=10) as socket:
            await socket.send(json.dumps([
                '1', '1', 'realtime:preprod-check', 'phx_join', {
                    'access_token': token,
                    'config': {
                        'broadcast': {'ack': False, 'self': False},
                        'presence': {'key': '', 'enabled': False},
                        'postgres_changes': [
                            {'event': 'INSERT', 'schema': 'public', 'table': 'transactions'}
                        ],
                        'private': False,
                    },
                },
            ]))
            reply = json.loads(await asyncio.wait_for(socket.recv(), timeout=10))
            if not isinstance(reply, list) or reply[4].get('status') != 'ok':
                raise RuntimeError('Local realtime server rejected the test subscription')
    except Exception:
        raise RuntimeError('Local realtime websocket test failed') from None


def main():
    result = subprocess.run(
        ['supabase', 'status', '--workdir', str(WORKDIR), '-o', 'env'],
        capture_output=True, text=True, check=True, shell=os.name == 'nt',
    )
    env = {}
    for line in result.stdout.splitlines():
        if '=' in line:
            key, value = line.split('=', 1)
            env[key] = value.strip().strip('"')
    if env.get('API_URL') != BASE:
        raise RuntimeError('Local API URL did not match the expected loopback address')
    anon = env['ANON_KEY']
    service = env['SERVICE_ROLE_KEY']
    email = f'preprod-{uuid4().hex}@example.test'
    user_id = None
    second_user_id = None
    try:
        signup = request('POST', '/auth/v1/signup', anon, data={
            'email': email, 'password': f'Test-{uuid4().hex}-aA1!',
        })
        user_id = str(UUID(signup['user']['id']))
        token = signup['access_token']
        second = request('POST', '/auth/v1/signup', anon, data={
            'email': f'preprod-{uuid4().hex}@example.test',
            'password': f'Test-{uuid4().hex}-aA1!',
        })
        second_user_id = str(UUID(second['user']['id']))
        # This Docker container name and the hardcoded loopback URL are local.
        local_sql(
            "UPDATE bicount_sync.capture_config SET pilot_user_uids = "
            f"pilot_user_uids || ARRAY['{user_id}'::uuid, '{second_user_id}'::uuid] "
            "WHERE singleton"
        )
        local_sql("NOTIFY pgrst, 'reload schema'")
        status = request('POST', '/rest/v1/rpc/bicount_sync_status', anon, token, {})
        if not status['enabled']:
            raise RuntimeError('Local journal pilot was not activated')
        asyncio.run(check_realtime(anon, token))
        friend_id = str(uuid4())
        transaction_id = str(uuid4())
        request('POST', '/rest/v1/friends', anon, token, {
            'sid': friend_id, 'fid': user_id, 'username': 'Test local',
            'relation_type': 0,
        })
        request('POST', '/rest/v1/transactions', anon, token, {
            'tid': transaction_id, 'gtid': str(uuid4()), 'uid': user_id,
            'name': 'Test local', 'type': 0, 'sender_id': user_id,
            'beneficiary_id': friend_id, 'date': '2026-01-01T00:00:00Z',
            'amount': 42, 'currency': 'CDF',
        })
        rows = request('GET', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token)
        if len(rows) != 1 or float(rows[0]['amount']) != 42:
            raise RuntimeError('Local transaction was not returned correctly')
        baseline = rows[0]
        request('PATCH', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token,
                {'amount': 43})
        stale = request('POST', '/rest/v1/rpc/bicount_conditional_mutation', anon, token, {
            'p_table': 'transactions', 'p_id': transaction_id, 'p_action': 'update',
            'p_expected': baseline, 'p_patch': {'amount': 99},
        })
        if stale.get('status') != 'conflict':
            raise RuntimeError('A stale local update was not rejected')
        stale_delete = request('POST', '/rest/v1/rpc/bicount_conditional_mutation', anon, token, {
            'p_table': 'transactions', 'p_id': transaction_id, 'p_action': 'delete',
            'p_expected': baseline,
        })
        if stale_delete.get('status') != 'conflict':
            raise RuntimeError('A stale local deletion was not rejected')
        current = request('GET', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token)
        if len(current) != 1 or float(current[0]['amount']) != 43:
            raise RuntimeError('The newer server transaction was not preserved')
        accepted = request('POST', '/rest/v1/rpc/bicount_conditional_mutation', anon, token, {
            'p_table': 'transactions', 'p_id': transaction_id, 'p_action': 'update',
            'p_expected': current[0], 'p_patch': {'amount': 44},
        })
        if accepted.get('status') != 'applied':
            raise RuntimeError('An unchanged baseline update was not applied')
        shared_baseline = request('GET', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token)[0]
        journal_marker = request('POST', '/rest/v1/rpc/bicount_sync_status', anon, token, {})
        request('PATCH', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token,
                {'amount': 47})
        request('PATCH', f'/rest/v1/transactions?tid=eq.{transaction_id}', anon, token,
                {'amount': 44})
        reverted = request('POST', '/rest/v1/rpc/bicount_conditional_journal_guard', anon, token, {
            'p_table': 'transactions', 'p_id': transaction_id, 'p_action': 'update',
            'p_expected': shared_baseline, 'p_patch': {'amount': 48},
            'p_seen_sequence': journal_marker['latest_sequence'],
            'p_generation': journal_marker['generation'],
        })
        if reverted.get('status') != 'conflict':
            raise RuntimeError('A changed-then-reverted server row was not protected')
        concurrent_marker = request('POST', '/rest/v1/rpc/bicount_sync_status', anon, token, {})
        def competing_write(amount):
            return request('POST', '/rest/v1/rpc/bicount_conditional_journal_guard', anon, token, {
                'p_table': 'transactions', 'p_id': transaction_id, 'p_action': 'update',
                'p_expected': shared_baseline, 'p_patch': {'amount': amount},
                'p_seen_sequence': concurrent_marker['latest_sequence'],
                'p_generation': concurrent_marker['generation'],
            })['status']
        with ThreadPoolExecutor(max_workers=2) as pool:
            outcomes = list(pool.map(competing_write, [45, 46]))
        if sorted(outcomes) != ['applied', 'conflict']:
            raise RuntimeError('Concurrent conditional updates did not serialize safely')
        events = request('GET', '/rest/v1/bicount_sync_events?order=sequence.asc', anon, token)
        if not any(e['table_name'] == 'transactions' and e['record_id'] == transaction_id for e in events):
            raise RuntimeError('Local journal did not contain the transaction')
        print('Local Auth, RLS, transaction and journal API: passed')
        test_env = os.environ.copy()
        test_env.update({
            'BICOUNT_PREPROD_TEST_ANON': anon,
            'BICOUNT_PREPROD_TEST_TOKEN': token,
            'BICOUNT_PREPROD_TEST_REFRESH': signup['refresh_token'],
            'BICOUNT_PREPROD_TEST_UID': user_id,
            'BICOUNT_PREPROD_TEST_SECOND_UID': second_user_id,
            'BICOUNT_PREPROD_TEST_SECOND_TOKEN': second['access_token'],
        })
        subprocess.run(
            ['flutter', 'test', 'supabase/tests/preprod_journal_integration_test.dart', '--no-pub'],
            cwd=ROOT, env=test_env, check=True, shell=os.name == 'nt',
        )
    finally:
        if user_id:
            local_sql(
                "UPDATE bicount_sync.capture_config SET pilot_user_uids = "
                f"array_remove(array_remove(pilot_user_uids, '{user_id}'::uuid), "
                f"'{second_user_id or user_id}'::uuid) WHERE singleton"
            )
            if second_user_id:
                request('DELETE', f'/auth/v1/admin/users/{second_user_id}', service, service)
            request('DELETE', f'/auth/v1/admin/users/{user_id}', service, service)
            local_sql(
                f"DELETE FROM public.bicount_sync_events WHERE user_uid IN ('{user_id}'::uuid, '{second_user_id or user_id}'::uuid); "
                f"DELETE FROM public.bicount_sync_clock WHERE user_uid IN ('{user_id}'::uuid, '{second_user_id or user_id}'::uuid)"
            )


if __name__ == '__main__':
    main()
