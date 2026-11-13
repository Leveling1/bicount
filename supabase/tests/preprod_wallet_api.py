"""Wallet regression against the loopback preproduction stack."""

import json
from uuid import UUID, uuid4

from preprod_api_smoke import BASE, ROOT, local_sql, request


def main():
    assert BASE == 'http://127.0.0.1:54321'
    config = json.loads((ROOT / 'supabase/.temp/bicount_preprod_defines.json').read_text())
    key = config['BICOUNT_LOCAL_ANON_KEY']
    accounts = []
    try:
        for _ in range(2):
            account = request('POST', '/auth/v1/signup', key, data={
                'email': f'wallet-{uuid4().hex}@example.test',
                'password': f'Test-{uuid4().hex}-aA1!',
            })
            accounts.append((str(UUID(account['user']['id'])), account['access_token']))
        (owner, owner_token), (friend, friend_token) = accounts
        own_wallet, = request('GET', '/rest/v1/wallets?is_default=eq.true', key, owner_token)
        other_wallet, = request('GET', '/rest/v1/wallets?is_default=eq.true', key, friend_token)
        assert own_wallet['owner_uid'] == owner and other_wallet['owner_uid'] == friend
        cash = str(uuid4())
        request('POST', '/rest/v1/wallets', key, owner_token, {
            'wallet_id': cash, 'owner_uid': owner, 'name': 'Cash', 'kind': 1,
        })
        transfer = str(uuid4())
        request('POST', '/rest/v1/transactions', key, owner_token, {
            'tid': transfer, 'name': 'Wallet transfer', 'uid': owner,
            'sender_id': owner, 'beneficiary_id': owner, 'type': 8,
            'date': '2026-01-01T12:00:00Z', 'amount': 5, 'currency': 'USD',
            'sender_wallet_id': own_wallet['wallet_id'], 'beneficiary_wallet_id': cash,
        })
        contact, tid = str(uuid4()), str(uuid4())
        request('POST', '/rest/v1/friends', key, owner_token, {'sid': contact, 'uid': friend, 'fid': owner})
        transaction = {
            'tid': tid, 'name': 'Wallet smoke', 'uid': owner,
            'sender_id': owner, 'beneficiary_id': contact, 'type': 0,
            'date': '2026-01-01T12:00:00Z', 'amount': 10, 'currency': 'USD',
            'sender_wallet_id': own_wallet['wallet_id'],
        }
        request('POST', '/rest/v1/transactions', key, owner_token, transaction)
        request('POST', '/rest/v1/rpc/set_transaction_wallet', key, friend_token, {
            'p_tid': tid, 'p_is_sender': False, 'p_wallet_id': other_wallet['wallet_id'],
        })
        req = f'/rest/v1/transactions?tid=eq.{tid}'
        request('PATCH', req, key, owner_token, {'note': 'Legacy edit'})
        row, = request('GET', req, key, friend_token)
        assert row['sender_wallet_id'] == own_wallet['wallet_id']
        assert row['beneficiary_wallet_id'] == other_wallet['wallet_id']
        plan = str(uuid4())
        request('POST', '/rest/v1/recurring_transfert', key, owner_token, {
            'recurring_transfert_id': plan, 'uid': owner, 'transaction_type': 3,
            'title': 'Wallet automatic salary', 'amount': 5, 'currency': 'USD',
            'sender_id': '', 'beneficiary_id': owner, 'frequency': 1,
            'start_date': '2026-01-01T12:00:00Z', 'next_due_date': '2026-01-01T12:00:00Z',
            'end_date': '2026-01-01T12:00:00Z', 'execution_mode': 1,
            'beneficiary_wallet_id': own_wallet['wallet_id'],
        })
        for _ in range(2):
            local_sql('SELECT bicount_wallet.generate_due_movements()')
        occurrence, = request('GET', f'/rest/v1/transactions?recurring_transfert_id=eq.{plan}', key, owner_token)
        assert occurrence['beneficiary_wallet_id'] == own_wallet['wallet_id']
        assert occurrence['generation_mode'] == 2
        for token, sender, target in [
            (friend_token, True, other_wallet['wallet_id']),
            (owner_token, True, other_wallet['wallet_id']),
        ]:
            try:
                request('POST', '/rest/v1/rpc/set_transaction_wallet', key, token, {
                    'p_tid': tid, 'p_is_sender': sender, 'p_wallet_id': target,
                })
            except RuntimeError as error:
                assert error.__cause__.code in (400, 403)
            else:
                raise AssertionError('Cross-party wallet assignment was accepted')
        print('Local wallet API passed')
    finally:
        for uid, _ in accounts:
            local_sql(f"DELETE FROM auth.users WHERE id = '{uid}'")


if __name__ == '__main__':
    main()
